// Defines a NetworkPolicy
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#networkpolicy-v1-networking-k8s-io
{
  // Required inputs
  local required = ' in an networkpolicy is required',
  name:: error '.name' + required,
  podSelector:: error '.podSelector' + required,

  // Definition
  namespace:: null,
  ingress:: null,
  egress:: null,

  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    [if $.namespace != null then 'namespace']: $.namespace,
    name: $.name,
  },
  spec: {
    podSelector: $.podSelector,
    [if $.ingress != null then 'ingress']: $.ingress,
    [if $.egress != null then 'egress']: $.egress,
  },
}
