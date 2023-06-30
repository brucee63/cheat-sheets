# Init Containers
This is a demonstration of using initContainers to stop creation of a pod until the dependent resource is avialable. In this case we have a `busybox` pod called `myapp`, with a container called `myapp-container` which will not start until an http default page hosted by an `nginx` web server is running and routable via a k8s service. <br />
The initContainers pod is using the `busybox` image as it's lightweight and we'll have access to the wget command which we'll use to verify the HTTP status code response (which should be 200) of the `nginx` web server.

## Tests
create namespace
```sh
kubectl create ns test-init
```

To debug 
```sh
kubectl run busybox --image=busybox:1.28 --restart=Never -n test-init --command sleep 3600 -
```

HTTP Status Codes command within busybox using wget <br />
note: this will return null if the service / site is not resolvable rather than an HTTP response code
```sh
wget --server-response nginx:8080 2>&1 | awk '/^  HTTP/{print $2}'
#ouput
200
```

now create our pod which is going to stay in the init containers stage until our nginx service is available
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
    image: harbor.nonprod.caas.energy.sug.pri/docker-hub-proxy/library/busybox:1.28
    command: ['sh', '-c', 'echo The app is now running because nginx is available! && sleep 3600']
  initContainers:
  - name: init-testnginx
    image: harbor.nonprod.caas.energy.sug.pri/docker-hub-proxy/library/busybox:1.28
    command:
    - 'sh'
    - '-c'
    - |
      RESPONSE=$(wget --server-response nginx:8080 2>&1 | awk '/^  HTTP/{print $2}');
      VAR1="${RESPONSE:-0}";
      until [[ $VAR1 = "200" ]];
      do
      echo waiting for nginx to be avialable;
      sleep 2;
      RESPONSE=$(wget --server-response nginx:8080 2>&1 | awk '/^  HTTP/{print $2}');
      VAR1="${RESPONSE:-0}";
      done;
EOF

kubectl apply -f myapp.yaml
```

create nginx app
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

expose it via a service
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

Now the myApp pod should have started
```sh
kubectl get pods -n test-init
```

cleanup/delete the namespace
```sh
kubectl delete ns test-init
```
