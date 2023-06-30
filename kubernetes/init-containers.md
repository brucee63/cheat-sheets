# Init Containers
This is a demonstration of using k8s initContainers to block creation of a pod until the dependent resource is avialable. In this case we have a `curl` pod called `myapp`, with a container called `myapp-container` which will not start until an http default page hosted by an `nginx` web server is running and routable via a k8s service. <br />
The initContainers pod is using the `curlimages/curl` image as it's lightweight and we'll have access to the `curl` command which we'll use to verify the HTTP status code response (200) of the `nginx` web server.

## Tests
create namespace
```sh
kubectl create ns test-init
```

To debug 
```sh
kubectl run curl --image=curlimages/curl:latest --restart=Never -n test-init --command sleep 3600 -
```

HTTP Status Codes via `curl` <br />
note: this will return 000 will if the service can't be reached
```sh
curl -sw '%{http_code}' nginx:8080 -o /dev/null
#ouput
200
```

Now create our pod which is going to stay in the init containers stage until our nginx service is available
```sh
cat <<EOF >>myapp.yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  namespace: test-init
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: curlimages/curl:latest
    command: ['sh', '-c', 'echo The app is now running because nginx is available! && sleep 3600']
  initContainers:
  - name: init-testnginx
    image: curlimages/curl:latest
    command: ["/bin/sh","-c"]
    args: ["while [ $(curl -sw '%{http_code}' nginx:8080 -o /dev/null) -ne 200 ]; do sleep 5; echo 'Waiting for the webserver...'; done"]
EOF

kubectl apply -f myapp.yaml
```


create nginx app, note we're using the unprivileged version
```sh
#kubectl create deployment nginx-deploy --image=nginx --replicas=1 -n test-init

cat <<EOF >>nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: test-init
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template: 
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginxinc/nginx-unprivileged:1
        ports:
        - containerPort: 8080
EOF

kubectl apply -f nginx-deployment.yaml
```

wait 10-15 seconds and verify we're still in init stage because the nginx pod isn't routable via nginx:8080 within the namespace yet -
```sh
kubectl get pods -n test-init
```

now expose it via a service
```sh
#kubectl expose rc nginx --port=80 --target-port=8000
cat <<EOF >>nginx-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: test-init
  labels:
    app: nginx
spec:
  selector:    
    app: nginx
  ports:
  - name: http
    port: 8080
    protocol: TCP
    targetPort: 8080
  type: ClusterIP
EOF

kubectl apply -f nginx-service.yaml
```

Now the myApp pod should start within 5-10s
```sh
kubectl get pods -n test-init
```

cleanup/delete the namespace
```sh
kubectl delete ns test-init
```
