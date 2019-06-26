# Sock Shop on k8s

This repo contains some manifests that allow you to run [the Sock Shop microservices demo](https://github.com/microservices-demo/microservices-demo) on k8s.

## Requisites

- a working kubernetes cluster and `kubectl` pointing to it.
- [`kubecfg`](https://github.com/bitnami/kubecfg) (alternatively you can use the compiled yaml with `kubectl`).

## How to operate

**Deploy using kubecfg**

```
$ # define ext variables
$ export EXT_VARS="catalogue.dbPassword=very-secure-password"
$ # deploy the application
$ kubecfg update --ext-str=${EXT_VARS} ./kubecfg/sockshop.jsonnet
```

**Generate raw k8s manifests**

```
$ # define ext variables
$ export EXT_VARS="catalogue.dbPassword=very-secure-password"
$ # generate manifests
$ kubecfg show --ext-str=${EXT_VARS} ./kubecfg/sockshop.jsonnet > sockshop.yaml
$ # sockshop.yaml can be used with kubectl
$ kubectl apply -f sockshop.yaml
```

**Deploy using kubectl (pre-defined EXT_VARS)**

This repo also includes [`sockshop.yaml`](./generated/sockshop.yaml). It contains a compilation of the k8s manifests with default values for `EXT_VARS`:

```
$ kubectl apply -f https://raw.githubusercontent.com/j-fuentes/sockshop-k8s/master/generated/sockshop.yaml

```

### Extra tips

For convenience, you can use the `Makefile` for common operations (generate, deploy, delete and diff):

```
$ # print help message
$ make
$ # deploy with default EXT_VARS
$ make deploy
```

# Caveats

**NetworkPolicies and GKE**

This solution makes use of NetworkPolicies in order to restric the communication between pods to the strictly necessary. If you are using GKE, [you might need to enable that feature in your cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/network-policy).
