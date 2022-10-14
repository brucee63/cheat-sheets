# Kubernetes

## delete all resources in a namespace
```sh
kubectl delete all --all -n namespace
```

## wait until pod is read

[link](https://reuvenharrison.medium.com/how-to-wait-for-a-kubernetes-pod-to-be-ready-one-liner-144bbbb5a76f) <br />
by pod name:
```sh
while [[ $(kubectl get pods hello-d8d8d7455-j9nzw -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
```

by label (deployment):
```sh
while [[ $(kubectl get pods -l app=hello -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
```