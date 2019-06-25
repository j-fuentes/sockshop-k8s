// Defines a Namespace
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#namespace-v1-core
{
  // Required inputs
  local required = ' in a namespace is required',
  name:: error '.name' + required,

  // Definition
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: $.name,
  },
}
