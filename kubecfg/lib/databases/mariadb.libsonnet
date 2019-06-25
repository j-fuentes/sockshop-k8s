// templates
local containerTpl = import '../templates/container.libsonnet';
local statefulsetTpl = import '../templates/statefulset.libsonnet';
local serviceTpl = import '../templates/service.libsonnet';
// mixins
local containerSec = import '../mixins/container_security.libsonnet';

{
  // Required inputs
  local required = ' in a mariadb is required',
  name:: error '.name' + required,
  labels:: error '.labels' + required,
  dbUser:: error '.dbUser' + required,
  dbPassword:: error '.dbPassword' + required,
  dbName:: error '.dbName' + required,

  // Definition
  namespace:: null,
  image:: 'mysql:5.7',
  port:: 3306,
  pvc:: null,

  volume:: if $.pvc != null then { name: $.pvc.name },
  volumeMounts:: [
    {
      name: $.volume.name,
      mountPath: '/var/lib/mysql',
    },
  ],

  statefulset: statefulsetTpl + {
    namespace: $.namespace,
    name: $.name,
    labels: $.labels,
    metadata+:{
      labels+: $.labels,
    },
    [if $.pvc != null then 'pvc']: $.pvc,
    [if $.volume != null then 'volumes']: [$.volume],
    serviceName: $.svc.name,
    [if $.pvc != null then 'initContainers']: [
      // GCE initializes the disk with a lost+found folder. This mislead the entrypoint in the mysql container,
      // since it checks if the volume is empty or not to decide if it is the first run.
      containerTpl + {
        name: 'prepare-volume',
        image: 'bash:5.0.7',
        [if $.volume != null then 'volumeMounts']: $.volumeMounts,
        command: ['bash', '-c', 'if [ ! -d \'/var/lib/mysql/mysql\' ]; then rm -rf /var/lib/mysql/lost+found; fi'],
      } + containerSec.capabilities.dropAll() + containerSec.filesystem.readOnly(),
    ],
    containers: [
      containerTpl + {
        name: 'db',
        image: $.image,
        env: [
          { name: 'MYSQL_USER', value: $.dbUser },
          { name: 'MYSQL_PASSWORD', value: $.dbPassword },
          { name: 'MYSQL_DATABASE', value: $.dbName },
          { name: 'MYSQL_ALLOW_EMPTY_PASSWORD', value: 'true' },
        ],
        ports: [
          { containerPort: $.port },
        ],
        [if $.volume != null then 'volumeMounts']: $.volumeMounts,
        probeExecCommand: ['sh', '-c', 'exec mysqladmin status'],
      },
    ],
  },

  svc: serviceTpl + {
    namespace: $.namespace,
    name: $.name,
    selector: $.labels,
    ports: [
      {
        name: 'mysql',
        port: $.port,
        targetPort: $.port,
      },
    ],
  },
}
