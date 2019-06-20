// Defines a StatefulSet
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#statefulset-v1-apps

local deploymentTpl = import './deployment.libsonnet';

deploymentTpl + {
  // Required inputs
  local required = ' in a statefulset is required',
  name:: error '.name' + required,
  labels:: error '.labels' + required,
  containers:: error '.containers' + required,
  serviceName:: error '.serviceName' + required,

  // Definition
  volumes:: [],
  pvc:: null,

  apiVersion: 'apps/v1',
  kind: 'StatefulSet',

  spec+: {
    strategy:: null,
    [if $.pvc != null then 'volumeClaimTemplates']: [$.pvc],
    serviceName: $.serviceName,
  },
}
