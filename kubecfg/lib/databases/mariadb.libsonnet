local containerTpl = import '../templates/container.libsonnet';
local statefulsetTpl = import '../templates/statefulset.libsonnet';
local serviceTpl = import '../templates/service.libsonnet';

{
  // Required inputs
  local required = ' in a service is required',
  name:: error '.name' + required,
  labels:: error '.labels' + required,
  dbUser:: error '.dbUser' + required,
  dbPassword:: error '.dbPassword' + required,
  dbName:: error '.dbName' + required,

  // Definition
  image:: 'mysql:5.7',
  port:: 3306,
  pvc:: null,

  volume:: if $.pvc != null then { name: $.pvc.name },

  deploy: statefulsetTpl + {
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
          { name: 'MYSQL_USER', value: $.dbUser },
          { name: 'MYSQL_PASSWORD', value: $.dbPassword },
          { name: 'MYSQL_DATABASE', value: $.dbName },
          { name: 'MYSQL_ALLOW_EMPTY_PASSWORD', value: 'true' },
        ],
        ports: [
          { containerPort: $.port },
        ],
        [if $.volume != null then 'volumeMounts']: [
          {
            name: $.volume.name,
            mountPath: '/var/lib/mysql',
          },
        ],
      },
    ],
  },

  svc: serviceTpl + {
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
