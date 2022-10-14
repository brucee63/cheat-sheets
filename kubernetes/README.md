# Kubernetes

## kubectl auto-completion
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

## delete all resources in a namespace
```sh
kubectl delete all --all -n namespace
```

## wait until pod is ready

[link](https://reuvenharrison.medium.com/how-to-wait-for-a-kubernetes-pod-to-be-ready-one-liner-144bbbb5a76f) <br />
script by pod name:
```sh
while [[ $(kubectl get pods hello-d8d8d7455-j9nzw -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
```

script by label (deployment):
```sh
while [[ $(kubectl get pods -l app=hello -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
```

```sh
kubectl wait --for=condition=ready pod -l app=netshoot
```

watch
```sh
kubectl get pods -w
```