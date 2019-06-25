// These mixins are intented to be complement a container object (see ../templates/container.libsonnet)
{
  capabilities: {
    // dropAll() drops all the capabilities in the container. Overrides the previously define capabilities if they exist.
    dropAll:: function() {
      securityContext+: {
        capabilities: {
          drop: ['all'],
        },
      },
    },

    // drop(caps) extends the existing list of capabilities that are dropped from the container.
    drop: function(caps=[]) {
      securityContext+: {
        capabilities+: {
          drop+: caps,
        },
      },
    },

    // add(caps) extends the existing list of capabilities that are added to the container.
    add: function(caps=[]) {
      securityContext+: {
        capabilities+: {
          add+: caps,
        },
      },
    },
  },
  filesystem: {
    readOnly:: function(on=true){ securityContext+: { readOnlyRootFilesystem: on } },
  },
  user: {
    nonRoot:: function(uid=10001) { securityContext+: {
      runAsNonRoot: true,
      runAsUser: uid,
    } },
  },
}
