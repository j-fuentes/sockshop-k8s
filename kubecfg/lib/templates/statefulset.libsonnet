// Defines a StatefulSet
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#statefulset-v1-apps

local deploymentTpl = import './deployment.libsonnet';

deploymentTpl + {
  // Required inputs
  local required = ' in a statefulset is required',
  name:: error '.name' + required,
  selector:: error '.selector' + required,
  containers:: error '.containers' + required,
  serviceName:: error '.serviceName' + required,

  // Definition
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',

  spec+: {
    strategy:: null,
    serviceName: $.serviceName,
  },
}
