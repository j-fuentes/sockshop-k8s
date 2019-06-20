// Templates
local containerTpl = import 'lib/templates/container.libsonnet';
local deploymentTpl = import 'lib/templates/deployment.libsonnet';
local serviceTpl = import 'lib/templates/service.libsonnet';
local ingressTpl = import 'lib/templates/ingress.libsonnet';
local pvTpl = import 'lib/templates/pv.libsonnet';
local pvcTpl = import 'lib/templates/pvc.libsonnet';
local mariadbTpl = import 'lib/databases/mariadb.libsonnet';
////

// Params

// labels that are shared among all the resources
local commonLabels = {
  app: 'sockshop',
  release: 'demo',
};

// whether the app is exposed to the world or not
local public = true;

////

// Resources
{
  frontend: {
    local frontendLabels = {
      tier: 'frontend',
    } + commonLabels,

    deploy: deploymentTpl + {
      name: 'frontend',
      labels: frontendLabels,
      metadata+:{
        labels+: frontendLabels,
      },
      containers: [
        containerTpl + {
          // https://github.com/microservices-demo/front-end
          image: 'weaveworksdemos/front-end:0.3.12',
          name: 'frontend',
          ports: [
            { containerPort: 8079 },
          ],
          probeHttpGet: { path: '/', port: 8079 },
        },
      ],
    },

    svc: serviceTpl + {
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
      name: 'frontend-ing',
      serviceName: $.frontend.svc.name,
      servicePort: 'web',
    },
  },

  catalogue: {
    local catalogueLabels = {
      tier: 'catalogue',
      tier2: 'server',
    } + commonLabels,

    local dbUser = 'catalogue',
    local dbPassword = 'very-secure-password',
    local dbName = 'catalogue',

    deploy: deploymentTpl + {
      name: 'catalogue',
      labels: catalogueLabels,
      metadata+:{
        labels+: catalogueLabels,
      },
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
        },
      ],
    },

    svc: serviceTpl + {
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
      name: 'catalogue-db',
      labels: {
        tier: 'catalogue',
        tier2: 'db',
      } + commonLabels,
      dbUser: dbUser,
      dbPassword: dbPassword,
      dbName: dbName,
      image: 'weaveworksdemos/catalogue-db:0.3.5',
      // persistence
      pvc: pvcTpl + {
        name: 'catalogue-db',
        storage: '20Gi',
        // selector: {
        //   matchLabels: $.catalogue.db.labels,
        // },
      },
      // pv: pvTpl + {
      //   name: 'catalogue-db',
      //   storage: $.catalogue.db.pvc.storage,
      //   labels: $.catalogue.db.labels,
      //   spec+: {
      //     gcePersistentDisk: {
      //       fsType: 'ext4',
      //       pdName: 'sockshop-catalogue-db',
      //     },
      //   },
      // },
    },
  },

  // TODO: add the other microservices
  order: {},
  payment: {},
  user: {},
  cart: {},
  shipping: {},
  queue: {},
  'queue-master': {},
}
