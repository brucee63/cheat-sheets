# Helm

## Installation

[Installation](https://helm.sh/docs/intro/install/)
```sh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

## Connecting to Kubernetes
By default, the helm command searches for the kube config in the following location ~/.kube/config , if stored in a different location the $KUBECONFIG environment variable can be set or the --kubeconfig flag
can be passed in as a parameter on helm commands.
<br />
The same is true of the kubectl context, if a default isn't set, you can set the $HELM_KUBECONTEXT environment variable or set the --kube-context flag on helm commands.

## Usage
```sh
helm repo list
helm search hub
helm search hub ingress-nginx

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update

#pull values.yaml chart file (to review and update)
helm pull ingress-nginx/ingress-nginx --untar
cd ingress-nginx
cat values.yaml

#installation
helm install ingress-nginx ingress-nginx/ingress-nginx -f values.yaml --namespace ingress-nginx

#upgrade, version can be optionally provided
helm upgrade ingress-nginx ingress-nginx/ingress-nginx --version 4.6.0 -f values.yaml --namespace ingress-nginx
```

## Exporting existing chart values.yaml
If you need to export existing chart settings
```sh
helm get values ingress-nginx -o yaml > values.yaml --namespace ingress-nginx
```
