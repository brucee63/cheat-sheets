# kustomize


## replace repo on images
This will replace the image repo globally on deployments where you add the appropriate label. Support for this is somewhat lacking with the `images` feature (useful for tags) or builtin transformers. This is using the `configMapGenerator`

In this example the existing image repo is `dev.imagerepo` and we want to replace it with `prod.imagerepo`, we're leaving the user/project alone here, but that could potentially be updated by changing the delimiter logic below. This is useful if you have a lot of images to replace and don't want configuration management sprawl.

Existing -
```
dev.imagerepo/test/busybox:1.28
```

New -
```
prod.imagerepo/test/busybox:1.28
```

`busybox-deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox
  namespace: default
  labels:
    customimage: "true"     # important if you have deployment images where you don't want the repo replaced, tag those as "false"
    initcontainers: "false" # if you have initContainers images which are custom and need to be replaced as well, tag these deployments as "true"
spec:
  replicas: 1
  template:
    metadata:
      name: busybox
      labels:
        app: busybox
    spec:
      containers:
      - image: dev.imagerepo/test/busybox:1.28  # registry to be updated
        command:
        - sleep
        - "3600"
      restartPolicy: Always
```

`.env`
```
IMAGEREPO=prod.imagerepo
```

`kustomization.yaml`
```yaml
resources:
  - busybox-deployment.yaml

configMapGenerator:
  - name: repo-config-map
    namespace: default
    envs:
      - .env

replacements:
  - source:
      # Replace any matches by the value of environment variable `IMAGEREPO`.
      kind: ConfigMap
      name: repo-config-map
      namespace: default
      fieldPath: data.IMAGEREPO
    targets:
      - select:
          # In each Deployment resource …
          kind: Deployment
          group: apps
          version: v1
          labelSelector: customimage=true   # use selectors if all of you deployments don't need repo replacement
        fieldPaths:
          # match the image
          - spec.template.spec.containers.*.image
        options:
          # … but replace only the repo part (image tag) when split by "/".
          delimiter: "/"
          index: 0
      - select:
          # In each Deployment resource …
          kind: Deployment
          group: apps
          version: v1
          labelSelector: inittests=true     # repo replacement for initContainers is a separate concern, and the need can differ per deployment
        fieldPaths:
          # match the initContainer image
          - spec.template.spec.initContainers.*.image          
        options:
          # … but replace only the repo part (image tag) when split by "/".
          delimiter: "/"
          index: 0

##uncomment to update the tag
#images:
#  - name: dev.imagerepo/test(.*)
#    newtag: newtag
```

run 
```sh
kustomize build ./repo-replacement
```

For the sake of completeness, a simple approach to use in a pinch. Just pipe the output of kustomize to sed and apply it -

```sh
kustomize build . | sed -E "s/dev.imagerepo/prod.imagerepo/" | kubectl apply -f -
```
