// Defines a Service
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#service-v1-core
{
  // Required inputs
  local required = ' in a service is required',
  name:: error '.name' + required,
  ports:: error '.ports' + required,
  selector:: error '.selector' + required,

  // Definition
  namespace:: null,
  type:: 'ClusterIP',

  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    [if $.namespace != null then 'namespace']: $.namespace,
    name: $.name,
  },
  spec: {
    type: $.type,
    ports: $.ports,
    selector: $.selector,
  },
}
