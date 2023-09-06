# Prometheus stack on Kubernetes
This assumes a minikube setup with docker as the driver in a VM. It also assumes Helm is setup.

Create a minikube with the 6g of ram
```sh
minikube start --kubernetes-version=v1.23.0 \
--memory=6g \
--bootstrapper=kubeadm \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.bind-address=0.0.0.0 \
--extra-config=controller-manager.bind-address=0.0.0.0 \
--extra-config=etcd.listen-metrics-urls=http://0.0.0.0:2381 \
--driver=docker
```

if you have another driver, just omit and it will pick up the default.

create the stack in the monitoring namespace
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create ns monitoring
kubectl create secret generic grafana-admin-credentials --from-literal admin-user="admin" --from-literal admin-password="admin-password" -n monitoring
```

get the internal ip address of the minikube node 
note that the values.yaml file has 127.0.0.1 for the server ip, this isn't allowed by the helm chart
so we need to sub in the correct ip address.
```sh
KUBEHOSTIP=$(k get nodes -o wide | awk 'NR>1 {print $6}')
echo $KUBEHOSTIP
cp values.yaml values-updated.yaml
sed -i s/127.0.0.1/$KUBEHOSTIP/g values-updated-ip.yaml
```

## create the prometheus stack
```sh
helm upgrade -i -n monitoring prometheus prometheus-community/kube-prometheus-stack -f values-updated-ip.yaml
```

wait for all pods to come up in monitoring namespace...
```sh
watch kubectl get pods -n monitoring
```

### port forward the services once all the pods are running (detached)
```sh
k port-forward -n monitoring service/grafana 3000:80 --address="0.0.0.0" & \
k port-forward -n monitoring service/prometheus-prometheus 9090:9090 --address="0.0.0.0" &
```

verify the prometheus and grafana dashboards

## install the blackbox-exporter
```sh
helm install prometheus-blackbox-exporter prometheus-community/prometheus-blackbox-exporter -n monitoring -f values-blackboxexporter.yaml
#kubectl apply -f probe-example.yaml
```

### port forward the services once all the pods are running (detached)
```sh
k port-forward -n monitoring service/prometheus-blackbox-exporter 9115:9115 --address="0.0.0.0" &
```

### import dashboard id # 7587 in grafana


## Monitoring Rabbitmq
First, you must have a rabbitmq instance running and have the prometheus plugin installed. This will expose metrics at port 15692 on the /metrics url.

Then uncomment the additionalScapreConfigs: section in the `values-updated-ip.yaml` helm values file for the promtheus stack. You can then upgrade the helm install
```sh
helm upgrade -i -n monitoring prometheus prometheus-community/kube-prometheus-stack -f values-updated-ip.yaml
```

You'll need to import the RabbitMQ Overview Dashboard in Grafana. It's dashboard # 10991

### to kill all port forwarding sessions
```sh
pkill kubectl -9
```

