# Kubernetes

## kubectl auto-completion and aliasing
[link](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/)
```sh
# verify bash-completion is installed 
type _init_completion

echo 'source <(kubectl completion bash)' >>~/.bashrc

# for k alias auto-completion (optional)
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

source ~/.bashrc
```

## change current namespace
```sh
kubectl config set-context --current --namespace=my-namespace
```

via alias
```sh
alias kubens='kubectl config set-context --current --namespace '
alias kubectx='kubectl config use-context '
```

## delete all resources in a namespace
```sh
kubectl delete all --all -n namespace
```

## wait until pod is ready

watch
```sh
kubectl get pods -w
```

```sh
kubectl wait --for=condition=ready pod -l app=nginx
```

[link](https://reuvenharrison.medium.com/how-to-wait-for-a-kubernetes-pod-to-be-ready-one-liner-144bbbb5a76f) <br />
script by pod name:
```sh
while [[ $(kubectl get pods hello-d8d8d7455-j9nzw -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
```

script by label (deployment):
```sh
while [[ $(kubectl get pods -l app=hello -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
```

## which kubernetes resources are in a namespace?
[link](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/#not-all-objects-are-in-a-namespace)
```sh
# In a namespace
kubectl api-resources --namespaced=true

# Not in a namespace
kubectl api-resources --namespaced=false
```

## CIDR ranges for services and pods
[link](https://stackoverflow.com/questions/44190607/how-do-you-find-the-cluster-service-cidr-of-a-kubernetes-cluster)
```sh
kubectl cluster-info dump | grep -m 1 cluster-ip-range
kubectl cluster-info dump | grep -m 1 cluster-cidr
```
