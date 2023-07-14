# services

## external FDQN
```sh
kind: Service
apiVersion: v1
metadata:
  name: google
  namespace: namespace-a
spec:
  type: ExternalName
  externalName: google.com
  ports:
  - port: 80
```

## service in another namespace
Note: it's required to have the `.svc.cluster.local` suffix when using the `ExternalName` property for a service in another local cluster namespace.
```sh
kind: Service
apiVersion: v1
metadata:
  name: service-y
  namespace: namespace-a
spec:
  type: ExternalName
  externalName: service-y.namespace-b.svc.cluster.local
  ports:
  - port: 80
```
