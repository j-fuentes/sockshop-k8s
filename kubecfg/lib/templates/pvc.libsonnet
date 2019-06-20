// Defines a PersistentVolumeClaim
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#persistentvolumeclaim-v1-core
{
  // Required inputs
  local required = ' in a pvc is required',
  name:: error '.name' + required,
  storage:: error '.storage' + required,

  // Definition
  selector:: null,
  volumeName:: null,

  apiVersion: 'core/v1',
  kind: 'PersistentVolumeClain',
  metadata: {
    name: $.name,
  },
  spec: {
    volumeMode: 'Filesystem',
    accessModes: ['ReadWriteOnce'],
    resources: {
      requests: {
        storage: $.storage,
      },
    },
    [if $.selector != null then 'selector']: $.selector,
    [if $.volumeName != null then 'volumeName']: $.volumeName,
  },
}
