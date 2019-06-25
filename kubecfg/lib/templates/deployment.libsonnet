// Defines a Deployment
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#deployment-v1-apps
{
  // Required inputs
  local required = ' in a deployment is required',
  name:: error '.name' + required,
  labels:: error '.labels' + required,
  containers:: error '.containers' + required,

  // Definition
  namespace:: null,
  volumes:: [],
  initContainers:: [],
  replicas:: 1,

  apiVersion: 'extensions/v1beta1',
  kind: 'Deployment',
  metadata: {
    [if $.namespace != null then 'namespace']: $.namespace,
    name: $.name,
    labels: $.labels,
  },
  spec: {
    replicas: $.replicas,
    selector: {
      matchLabels: $.labels,
    },
    template: (import 'pod_template_spec.libsonnet') + {
      name: $.name,
      initContainers: $.initContainers,
      containers: $.containers,
      volumes: $.volumes,
      metadata+: {
        labels: $.labels,
      }
    },
    strategy: {
      type: 'RollingUpdate',
      rollingUpdate: {
        maxSurge: 1,
        maxUnavailable: 1,
      },
    },
  },
}
