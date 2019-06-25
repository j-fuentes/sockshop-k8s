// Defines a PersistentVolumeClaim
// https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#persistentvolumeclaim-v1-core
{
  // Required inputs
  local required = ' in a pvc is required',
  name:: error '.name' + required,
  storage:: error '.storage' + required,

  // Definition
  namespace:: null,
  selector:: null,
  volumeName:: null,
  storageClassName:: null,

  apiVersion: 'core/v1',
  kind: 'PersistentVolumeClain',
  metadata: {
    [if $.namespace != null then 'namespace']: $.namespace,
    name: $.name,
  },
  spec: {
    volumeMode: 'Filesystem',
    accessModes: ['ReadWriteOnce'],
    [if $.storageClassName != null then 'storageClassName']: $.storageClassName,
    resources: {
      requests: {
        storage: $.storage,
      },
    },
    [if $.selector != null then 'selector']: $.selector,
    [if $.volumeName != null then 'volumeName']: $.volumeName,
  },
}
