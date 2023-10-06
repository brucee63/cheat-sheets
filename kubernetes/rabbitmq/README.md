I've looked at both Traefik and NGINX for the RabbitMQ external access use case. For RabbitMQ, NGINX Ingress ended up being the simpler option for me to expose the AMQP protocol via TCP. It's also the default ingress provider for minikube (if you enable it), which is useful. Both seem the handle HTTP/HTTPS equally well, but Traefik appeared to require more explict/verbose TCP configuration to setup.

Note, there is nothing stopping you from having more than one ingress controller in use on a cluster for different purposes/use cases.

spin up a cluster, if using minikube -
```sh
minikube delete && minikube start --kubernetes-version=v1.23.0 --memory=6g --bootstrapper=kubeadm --extra-config=kubelet.authentication-token-webhook=true --extra-config=kubelet.authorization-mode=Webhook --extra-config=scheduler.bind-address=0.0.0.0 --extra-config=controller-manager.bind-address=0.0.0.0 --extra-config=etcd.listen-metrics-urls=http://0.0.0.0:2381 --driver=docker
```

After we have a kubernetes cluster, we need a rabbitmq cluster. I'm using the rabbitmq operator to provision -

Install the latest RabbitMQ operator (if necessary)
```sh
kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
```

wait for operator to be ready
```sh
watch kubectl get pods -n rabbitmq-system
```

namespace for rabbitmq test-cluster
```sh
kubectl create ns test-rabbitmq
```

create the cluster -
test-cluster.yaml
```yaml
apiVersion: rabbitmq.com/v1beta1
kind: RabbitmqCluster
metadata:
  name: test-cluster
  namespace: test-rabbitmq
spec:
  replicas: 1
```

```sh
kubectl apply -f test-cluster.yaml
```
wait for cluster to be ready
```sh
watch kubectl get pods -n test-rabbitmq
```

Next you need a service of ClusterIP type to expose the management portal and AMQP via Ingress, we'll expose ports 5672, 15672 (and if you want to expose the prometheus metrics endpoint, 15692). Port 5671 would be for AMQP TLS.

cluster-service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/component: rabbitmq
    app.kubernetes.io/name: cluster-service
    app.kubernetes.io/part-of: rabbitmq
  name: cluster-service
  namespace: test-rabbitmq
spec:
  ipFamilies:
    - IPv4
  ipFamilyPolicy: SingleStack
  ports:
    # - appProtocol: amqp
    #   name: amqp-tls
    #   port: 5671
    #   protocol: TCP
    #   targetPort: 5671
    - appProtocol: amqp
      name: amqp
      port: 5672
      protocol: TCP
      targetPort: 5672
    - appProtocol: http
      name: management
      port: 15672
      protocol: TCP
      targetPort: 15672
    - appProtocol: prometheus.io/metrics
      name: prometheus
      port: 15692
      protocol: TCP
      targetPort: 15692
  selector:
    app.kubernetes.io/name: test-cluster
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
```

```sh
kubectl apply -f cluster-service.yaml
```

## setup ingress (minikube only!)
```sh
minikube addons enable ingress
#kubectl patch configmap tcp-services -n ingress-nginx --patch '{"data":{"5671":"test-rabbitmq/cluster-service:5671"}}'
kubectl patch configmap tcp-services -n ingress-nginx --patch '{"data":{"5672":"test-rabbitmq/cluster-service:5672"}}'
```

```ingress-nginx-controller-patch.yaml
spec:
  template:
    spec:
      containers:
      - name: controller
        ports:
#         - containerPort: 5671
#           hostPort: 5671   
         - containerPort: 5672
           hostPort: 5672
```

```sh
kubectl patch deployment ingress-nginx-controller --patch "$(cat ingress-nginx-controller-patch.yaml)" -n ingress-nginx
# after the ingress pod is back up and running
telnet $(minikube ip) 5672
# Ctrl+] then quit
```

## setup ingress (helm)
install the ingress-nginx controller (if necessary)
```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

This handles exposing the TCP ports for AMQP, it maps those ports to our service ports we created previously -
values.yaml
```yaml
controller:
  replicaCount: 1
  service:
    loadBalancerIP: "192.168.1.251"	# IP reserved for ingress. If you omit, you'll be assigned an IP in the avaiable range. Better to specify one.
tcp:
  #5671: test-rabbitmq/cluster-service:5671
  5672: test-rabbitmq/cluster-service:5672
udp: {}
```

create our nginx ingress controller
```sh
helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx -f values.yaml -n ingress-nginx --create-namespace
```

Once the nginx cluster pods are up -
```sh
watch kubectl get pods -n ingress-nginx
telnet $(minikube ip) 5672
# Ctrl+] then quit
```

let's expose our HTTP ingress -
rabbitmq-ingress.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rabbitmq-ingress
  namespace: test-rabbitmq
spec:
  ingressClassName: nginx
  rules:
    - host: rabbitmq.test
      http:
        paths:    
          - backend:
              service:
                name: cluster-service
                port:
                  number: 15692
            path: /metrics	# optional
            pathType: Exact  
          - backend:
              service:
                name: cluster-service
                port:
                  number: 15672
            path: /
            pathType: Prefix
  defaultBackend:
    service:
      name: cluster-service
      port:
        number: 15672
status:
  loadBalancer: {}
```

```sh
kubectl apply -f rabbitmq-ingress.yaml
```

wait for an external address to be assigned to your ingress
```sh
watch kubectl get ingress -n test-rabbitmq
```

Note: you can adjust the ingress to support TLS/HTTPS, but that's beyond the scope of this example.

add a rabbitmq.test hosts entry mapped to 192.168.1.251 (or whatever IP you assigned, or was assigned to the NGINX Ingress)

## if using minikube
```sh
sudo -- sh -c "echo '$(minikube ip)  rabbitmq.test' >> /etc/hosts"
```

## if using helm installed ingress controller
```sh
sudo -- sh -c "echo $(kubectl get ingress -n test-rabbitmq -o=jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}'  rabbitmq.test >> /etc/hosts"
```

example hosts entry -
```
192.168.1.251  rabbitmq.test
```

Verify we get HTML and stats back via ingress
```sh
curl rabbitmq.test
curl rabbitmq.test/metrics # bonus
```

get the rabbitmq management portal user/password (if not exmplicitly specified when the cluster was created)
```sh
kubectl get secret test-cluster-default-user -n test-rabbitmq -o jsonpath='{.data.username}' | base64 --decode
kubectl get secret test-cluster-default-user -n test-rabbitmq -o jsonpath='{.data.password}' | base64 --decode
```

You should be able to connect to the management portal using these credentials from a web browser
```
http://rabbitmq.test
http://rabbitmq.test/metrics
```

## minikube expose ingress to host machine
if you're running minikube in a VM, to expose the ingress to the host so you can access the management portal from a web browser, do the following. Then port map 80 (host) to 8080 (vm) in your hypervisor -
```sh
# we forward to 8080 because 80 is a privileged port
kubectl port-forward --address 0.0.0.0 deployment/ingress-nginx-controller 8080:80 --namespace ingress-nginx
# following for TLS
#kubectl port-forward --address 0.0.0.0 deployment/ingress-nginx-controller 8443:443 --namespace ingress-nginx
```

From the .NET client, you can now test connectivity to the TCP port 5672 using the host entry or ingress IP. If running the .NET client from your host machine into a VM (minikube), port forward TCP 5672:5672

That's should do it. I've verified this in minikube and have done the same on actual clusters using helm for nginx ingress.

## multiple cluster considerations
Note: if you're hosting multiple rabbitmq clusters (from a single kubernetes cluster), you'll have to map to different externally available ports on the same ingress IP (e.g. 5782 -> test-rabbitmq-2/cluster-service:5672).

Alternatively, you could run multiple instances of an ingress controller, but there is additional overhead (and complexity) using this approach.
