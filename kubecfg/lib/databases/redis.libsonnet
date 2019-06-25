// templates
local containerTpl = import '../templates/container.libsonnet';
local deploymentTpl = import '../templates/deployment.libsonnet';
local serviceTpl = import '../templates/service.libsonnet';
// mixins
local containerSec = import '../mixins/container_security.libsonnet';

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
        probeExecCommand: ['sh', '-c', 'exec redis-cli ping'],
      } + containerSec.capabilities.dropAll() + containerSec.filesystem.readOnly() + containerSec.user.nonRoot(),
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
