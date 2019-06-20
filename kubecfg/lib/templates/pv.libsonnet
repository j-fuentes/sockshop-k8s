// Defines a PersistentVolume
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#persistentvolume-v1-core
{
  // Required inputs
  local required = ' in a pv is required',
  name:: error '.name' + required,
  storage:: error '.storage' + required,
  disk:: error '.disk' + required,

  // Definition
  labels:: [],

  apiVersion: 'v1',
  kind: 'PersistentVolume',
  metadata: {
    name: $.name,
    labels: $.labels,
  },
  spec: {
    volumeMode: 'Filesystem',
    accessModes: ['ReadWriteOnce'],
    capacity: {
      storage: $.storage,
    },
    persistentVolumeReclaimPolicy: 'Retain',
  },
}
