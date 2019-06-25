local containerTpl = import '../templates/container.libsonnet';
local deploymentTpl = import '../templates/deployment.libsonnet';
local serviceTpl = import '../templates/service.libsonnet';

{
  // Required inputs
  local required = ' in a redis is required',
  name:: error '.name' + required,
  labels:: error '.labels' + required,

  // Definition
  image:: 'redis:5.0.5',
  port:: 6379,

  deploy: deploymentTpl + {
    name: $.name,
    labels: $.labels,
    metadata+:{
      labels+: $.labels,
    },
    containers: [
      containerTpl + {
        name: 'redis',
        image: $.image,
        ports: [
          { containerPort: $.port },
        ],
      },
    ],
  },

  svc: serviceTpl + {
    name: $.name,
    selector: $.labels,
    ports: [
      {
        name: 'redis',
        port: $.port,
        targetPort: $.port,
      },
    ],
  },
}
