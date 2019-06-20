// Defines a PodTemplateSpec
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#podtemplatespec-v1-core
{
  // Required input
  local required = ' in a pod_template_spec is required',
  name:: error '.name' + required,
  containers:: error '.containers' + required,

  // Definition
  volumes:: [],
  initContainers:: [],

  metadata: {
    name: $.name,
  },
  spec: {
    initContainers: $.initContainers,
    containers: $.containers,
    volumes: $.volumes,
    restartPolicy: 'Always',
  }
}
