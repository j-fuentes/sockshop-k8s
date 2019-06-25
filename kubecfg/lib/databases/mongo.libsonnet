// templates
local containerTpl = import '../templates/container.libsonnet';
local statefulsetTpl = import '../templates/statefulset.libsonnet';
local serviceTpl = import '../templates/service.libsonnet';
// mixins
local containerSec = import '../mixins/container_security.libsonnet';

{
  // Required inputs
  local required = ' in a mongo is required',
  name:: error '.name' + required,
  labels:: error '.labels' + required,
  dbUser:: error '.dbUser' + required,
  dbPassword:: error '.dbPassword' + required,
  dbName:: error '.dbName' + required,

  // Definition
  image:: 'mongo:4.1-bionic',
  port:: 27017,
  pvc:: null,

  volume:: if $.pvc != null then { name: $.pvc.name },
  volumeMounts:: [
    {
      name: $.volume.name,
      mountPath: '/data/db',
    },
  ],

  statefulset: statefulsetTpl + {
    name: $.name,
    labels: $.labels,
    metadata+:{
      labels+: $.labels,
    },
    [if $.pvc != null then 'pvc']: $.pvc,
    [if $.volume != null then 'volumes']: [$.volume],
    serviceName: $.svc.name,
    containers: [
      containerTpl + {
        name: 'db',
        image: $.image,
        env: [
          { name: 'MONGO_INITDB_ROOT_USERNAME', value: $.dbUser },
          { name: 'MONGO_INITDB_ROOT_PASSWORD', value: $.dbPassword },
          { name: 'MONGO_INITDB_DATABASE', value: $.dbName },
        ],
        ports: [
          { containerPort: $.port },
        ],
        [if $.volume != null then 'volumeMounts']: $.volumeMounts,
        probeExecCommand: ['sh', '-c', 'echo \'db.runCommand("ping").ok\' | mongo localhost:' + $.port + '/test --quiet'],
      },
    ],
  },

  svc: serviceTpl + {
    name: $.name,
    selector: $.labels,
    ports: [
      {
        name: 'mongo',
        port: $.port,
        targetPort: $.port,
      },
    ],
  },
}
