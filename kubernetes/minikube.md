# Minikube

## setup
```sh
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

```sh
minikube delete && minikube start --kubernetes-version=v1.23.0 --memory=6g --bootstrapper=kubeadm --extra-config=kubelet.authentication-token-webhook=true --extra-config=kubelet.authorization-mode=Webhook --extra-config=scheduler.bind-address=0.0.0.0 --extra-config=controller-manager.bind-address=0.0.0.0 --extra-config=etcd.listen-metrics-urls=http://0.0.0.0:2381
```

### enable ingress
```sh
minikube addons enable ingress
```

### port forward (ingress controller in this example)
```sh
kubectl port-forward --address 0.0.0.0 deployment/ingress-nginx-controller 8080:80 --namespace ingress-nginx
```

### port forward (get prompt back)
```sh
kubectl port-forward -n monitoring service/grafana 3000:80 --address="0.0.0.0" & \
# then kill later
pkill kubectl -9
```
