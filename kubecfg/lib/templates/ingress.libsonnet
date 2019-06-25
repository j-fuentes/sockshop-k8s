// Defines an Ingress
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#ingress-v1beta1-extensions
{
  // Required inputs
  local required = ' in an ingress is required',
  name:: error '.name' + required,
  serviceName:: error '.serviceName' + required,
  servicePort:: error '.servicePort' + required,

  // Definition
  namespace:: null,

  apiVersion: 'extensions/v1beta1',
  kind: 'Ingress',
  metadata: {
    [if $.namespace != null then 'namespace']: $.namespace,
    name: $.name,
  },
  spec: {
    rules: [
      {
        http: {
          paths: [
            {
              backend: {
                serviceName: $.serviceName,
                servicePort: $.servicePort,
              },
            },
          ],
        },
      },
    ],
  },
}
