// Defines a Container
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#container-v1-core
{
  // Required inputs
  local required = ' in a container is required',
  image: error '.image' + required,
  name: error '.name' + required,

  // Definition
  probeHttpGet:: null,

  ports: [],
  env: [],
  livenessProbe: if $.probeHttpGet != null then {
    failureThreshold: 2,
    httpGet: $.probeHttpGet,
    initialDelaySeconds: 15,
    periodSeconds: 10,
    successThreshold: 1,
    timeoutSeconds: 3,
  },
  readinessProbe: $.livenessProbe,
  resources: {
    requests: { cpu: '100m', memory: '50Mi' },
    limits: { cpu: '1', memory: '512Mi' },
  },
}
