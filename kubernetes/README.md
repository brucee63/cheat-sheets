# Kubernetes

## install kubectl
```sh
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

## kubectl auto-completion and aliasing
[link](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#bash)
```sh
# verify bash-completion is installed 
type _init_completion

echo 'source <(kubectl completion bash)' >>~/.bashrc

# for k alias auto-completion (optional)
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

source ~/.bashrc
```

```sh
# for zsh, add to .zshrc ->
source <(kubectl completion zsh)
source .zshrc
```

## change current namespace
```sh
kubectl config set-context --current --namespace=my-namespace
```

## view current namespace
```sh
kubectl config view --minify | grep namespace:
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

## delete all pods in a namespace matching a particular pattern
```sh
kubectl get pods -n mynamespace --no-headers=true | awk '/patterntomatch/{print $1}'| xargs  kubectl delete -n mynamespace pod
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

## Get podsecuritypolicy for a pod (using jsonpath)
```sh
k get pod -n mynamespace mypod -o jsonpath={.metadata.annotations}
```
