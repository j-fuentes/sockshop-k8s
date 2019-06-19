// Templates
local containerTpl = import 'lib/templates/container.libsonnet';
local deploymentTpl = import 'lib/templates/deployment.libsonnet';
local serviceTpl = import 'lib/templates/service.libsonnet';
local ingressTpl = import 'lib/templates/ingress.libsonnet';
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
      name: 'frontend-deploy',
      selector: frontendLabels,
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
      name: 'frontend-svc',
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

  order: {},

  payment: {},

  user: {},

  catalogue: {},

  cart: {},

  shipping: {},

  queue: {},

  'queue-master': {},
}
