// Templates
local namespaceTpl = import 'lib/templates/namespace.libsonnet';
local containerTpl = import 'lib/templates/container.libsonnet';
local deploymentTpl = import 'lib/templates/deployment.libsonnet';
local serviceTpl = import 'lib/templates/service.libsonnet';
local ingressTpl = import 'lib/templates/ingress.libsonnet';
local pvcTpl = import 'lib/templates/pvc.libsonnet';
local networkpolicyTpl = import 'lib/templates/networkpolicy.libsonnet';
local mariadbTpl = import 'lib/databases/mariadb.libsonnet';
local redisTpl = import 'lib/databases/redis.libsonnet';
local mongoTpl = import 'lib/databases/mongo.libsonnet';
// mixins
local containerSec = import 'lib/mixins/container_security.libsonnet';

// Params

// labels that are shared among all the resources
local commonLabels = {
  app: 'sockshop',
  release: 'demo',
};

// whether the app is exposed to the world or not
local public = true;

local namespace = 'sockshop';

// Resources
{
  local netpolAllowFrontendIngress = {from: [{ podSelector: { matchLabels: $.frontend.deploy.labels } }]},

  namespace: namespaceTpl + {
    name: namespace,
  },

  frontend: {
    local frontendLabels = {
      tier: 'frontend',
      tier2: 'server',
    } + commonLabels,

    deploy: deploymentTpl + {
      namespace: namespace,
      name: 'frontend',
      labels: frontendLabels,
      containers: [
        containerTpl + {
          // https://github.com/microservices-demo/front-end
          image: 'weaveworksdemos/front-end:0.3.12',
          name: 'frontend',
          ports: [
            { containerPort: 8079 },
          ],
          probeHttpGet: { path: '/', port: 8079 },
          env: [
            { name: 'SESSION_REDIS', value: 'true' },
          ],
        } + containerSec.capabilities.dropAll() + containerSec.filesystem.readOnly() + containerSec.user.nonRoot(),
      ],
    },

    svc: serviceTpl + {
      namespace: namespace,
      name: 'frontend',
      // The native GKE Ingress controller only supports NodePort services
      type: 'NodePort',
      selector: frontendLabels,
      ports: [
        {
          name: 'web',
          port: 80,
          targetPort: 8079,
        },
      ],
    },

    ing: if public then ingressTpl + {
      namespace: namespace,
      name: 'frontend-ing',
      serviceName: $.frontend.svc.name,
      servicePort: 'web',
    },

    'session-db': redisTpl + {
      namespace: namespace,
      name: 'session-db',
      labels: frontendLabels + { tier2: 'session-db' },
    } + {
      netpol: networkpolicyTpl + {
        namespace: namespace,
        name: 'session-db',
        podSelector: { matchLabels: $.frontend['session-db'].labels },
        ingress: [netpolAllowFrontendIngress],
      },
    },
  },

  catalogue: {
    local catalogueLabels = {
      tier: 'catalogue',
      tier2: 'server',
    } + commonLabels,

    local dbUser = 'catalogue',
    local dbPassword = std.extVar('catalogue.dbPassword'),
    local dbName = 'catalogue',

    deploy: deploymentTpl + {
      namespace: namespace,
      name: 'catalogue',
      labels: catalogueLabels,
      containers: [
        containerTpl + {
          // https://github.com/microservices-demo/catalogue
          image: 'weaveworksdemos/catalogue:0.3.5',
          name: 'catalogue',
          command: ['/app', '-port=80', '-DSN='+dbUser+':'+dbPassword+'@tcp('+$.catalogue.db.svc.name+':'+3306+')/'+dbName],
          ports: [
            { containerPort: 80 },
          ],
          probeHttpGet: { path: '/health', port: 80 },
        } + containerSec.capabilities.dropAll() + containerSec.capabilities.add(['NET_BIND_SERVICE'])
        + containerSec.filesystem.readOnly() + containerSec.user.nonRoot(),
      ],
    },

    svc: serviceTpl + {
      namespace: namespace,
      name: 'catalogue',
      selector: catalogueLabels,
      ports: [
        {
          name: 'web',
          port: 80,
          targetPort: 80,
        },
      ],
    },

    db: mariadbTpl + {
      namespace: namespace,
      name: 'catalogue-db',
      labels: catalogueLabels + { tier2: 'db' },
      dbUser: dbUser,
      dbPassword: dbPassword,
      dbName: dbName,
      image: 'weaveworksdemos/catalogue-db:0.3.5',
      pvc: pvcTpl + {
        name: 'catalogue-db',
        storage: '20Gi',
        storageClassName: 'standard',
      },
    } + {
      netpol: networkpolicyTpl + {
        namespace: namespace,
        name: 'catalogue-db',
        podSelector: { matchLabels: $.catalogue.db.labels },
        ingress: [{ from: [{ podSelector: { matchLabels: $.catalogue.deploy.labels } }] }],
      },
    },

    netpol: networkpolicyTpl + {
      namespace: namespace,
      name: 'catalogue',
      podSelector: { matchLabels: $.catalogue.deploy.labels },
      ingress: [netpolAllowFrontendIngress],
    },
  },

  carts: {
    local cartsLabels = {
      tier: 'carts',
      tier2: 'server',
    } + commonLabels,

    // The carts application is not easy to configure externally and it defaults to empty user and password.
    local dbUser = null,
    local dbPassword = null,
    local dbName = null,

    deploy:  deploymentTpl + {
      namespace: namespace,
      name: 'carts',
      labels: cartsLabels,
      containers: [
        containerTpl + {
          // https://github.com/microservices-demo/carts
          image: 'weaveworksdemos/carts:0.4.8',
          name: 'carts',
          ports: [
            { containerPort: 80 },
          ],
          env: [
            {
              name: 'JAVA_OPTS',
              value: '-Xms64m -Xmx128m -XX:PermSize=32m -XX:MaxPermSize=64m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom',
            },
          ],
          volumeMounts: [
            {
              name: 'tmp',
              mountPath: '/tmp',
            },
          ],
          probeHttpGet: { path: '/health', port: 80 },
          local probesTimes = {
            initialDelaySeconds: 60,
            periodSeconds: 15,
          },
          livenessProbe+: probesTimes,
          readinessProbe+: probesTimes,
        } + containerSec.capabilities.dropAll() + containerSec.capabilities.add(['NET_BIND_SERVICE'])
        + containerSec.filesystem.readOnly() + containerSec.user.nonRoot(),
      ],
      volumes: [
        {
          name: 'tmp',
          emptyDir: { medium: 'Memory' },
        },
      ],
    },

    svc: serviceTpl + {
      namespace: namespace,
      name: 'carts',
      selector: cartsLabels,
      ports: [
        {
          name: 'web',
          port: 80,
          targetPort: 80,
        },
      ],
    },

    db: mongoTpl + {
      namespace: namespace,
      name: 'carts-db',
      labels: cartsLabels + { tier2: 'db' },
      dbUser: dbUser,
      dbPassword: dbPassword,
      dbName: dbName,
      pvc: pvcTpl + {
        name: 'cart-db',
        storage: '20Gi',
        storageClassName: 'standard',
      },
    } + {
      netpol: networkpolicyTpl + {
        namespace: namespace,
        name: 'carts-db',
        podSelector: { matchLabels: $.carts.db.labels },
        ingress: [{ from: [{ podSelector: { matchLabels: $.carts.deploy.labels } }] }],
      },
    },

    netpol: networkpolicyTpl + {
      namespace: namespace,
      name: 'carts',
      podSelector: { matchLabels: $.carts.deploy.labels },
      ingress: [netpolAllowFrontendIngress],
    },
  },

  // TODO: add the other microservices
  order: {},
  payment: {},
  user: {},
  shipping: {},
  queue: {},
  'queue-master': {},
}
