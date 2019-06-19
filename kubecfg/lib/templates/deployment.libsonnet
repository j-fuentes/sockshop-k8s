// Defines a Deployment
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#deployment-v1-apps
{
  // Required inputs
  local required = ' in a deployment is required',
  name:: error '.name' + required,
  selector:: error '.selector' + required,
  containers:: error '.containers' + required,

  // Definition
  volumes:: [],

  apiVersion: 'extensions/v1beta1',
  kind: 'Deployment',
  metadata: {
    name: $.name,
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: $.selector,
    },
    template: (import 'pod_template_spec.libsonnet') + {
      name: $.name,
      containers: $.containers,
      volumes: $.volumes,
      metadata+: {
        labels: $.selector,
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
