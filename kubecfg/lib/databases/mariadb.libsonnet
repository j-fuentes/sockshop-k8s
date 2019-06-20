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

  deploy: statefulsetTpl + {
    name: $.name,
    selector: $.labels,
    metadata+:{
      labels+: $.labels,
    },
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
