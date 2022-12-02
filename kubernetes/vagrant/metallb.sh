#!/bin/bash

#https://metallb.universe.tf/installation/
#https://www.youtube.com/watch?v=2SmYjj-GFnE

# determine host network range
sudo apt install sipcalc

# note: your ip range will be different.
ip a s 
# 192.168.55.50/24

sipcalc 192.168.55.50/24
# usable range 192.168.55.1 - 192.168.55.254
# port in use between nodes for metallb is 7946 TCP & UDP

# if you are using kube-proxy in IPVS mode?
kubectl -n kube-system get all
kubectl -n kube-system get cm

kubectl -n kube-system describe cm kube-proxy | less

# see what changes would be made, returns nonzero returncode if different
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

# actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml

kubectl -n metallb-system get all

# be sure to update to your specific local ip range based on first few steps.
kubectl create -f metallb.yaml

# test 
kubectl create deploy nginx --image nginx
kubectl expose deploy nginx --port 80 --type LoadBalancer

kubectl get service