
# Sealed-secrets

[git repo](https://github.com/bitnami-labs/sealed-secrets)

## helm install
```sh
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update

helm upgrade -i sealed-secrets -n kube-system --set-string fullnameOverride=sealed-secrets-controller sealed-secrets/sealed-secrets
```

## install client (linux)
```sh
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.22.0/kubeseal-0.22.0-linux-amd64.tar.gz
tar -xvzf kubeseal-0.22.0-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

## example usage
The following example will show how to create and encrypt a generic sealed secret. This sealed secret would be stored in source code control (git repo) and is only applicable/usable on the cluster where it was generated. <br /> NOTE: If the cluster is recreated, the sealed secrets will need to be recreated and replaced in SCC.

### create a secret
```sh
kubectl create ns sealedsecret-test

kubectl -n sealedsecret-test create secret generic user-creds --from-literal domain="mydomain" --from-literal username="myuser" --from-literal password='mysecretpassword' --dry-run=client -o yaml > user-creds.yaml
```

Note: I ran into an issue where the sealed secret operator wasn't able to create the secret without this cluster-wide option. You can't change the namespace of the secret with the default scope. If you're using Kustomize and changing the namespace on your secrets via patching, this will be necessary. For more information on [scopes](https://github.com/bitnami-labs/sealed-secrets#scopes)

### seal the secret
```sh
kubeseal --scope cluster-wide <user-creds.yaml >user-creds-sealed.yaml
```

### verify the sealed-secret is valid
Note: you should receive no output if this is valid
```sh
cat user-creds-sealed.yaml | kubeseal --validate
```

### apply the sealed secret
```sh
kubectl create -f user-creds-sealed.yaml
```

### verify the secret was created in the namespace
```sh
kubectl get secret -n sealedsecret-test
```

Note: If the secret wasn't created, check the status of the sealedsecret in the same namespace
```sh
kubectl get sealedsecret -n sealedsecret-test
```

Note: If the secret already exists, it will not be able to be managed by sealed secrets. Please see the docs for more details on how to patch.

### see that we have base-64 encoded values for domain, username and password
```sh
kubectl get secret -n sealedsecret-test user-creds -o yaml
```

### take the domain base-64 encoded value from the secret and decode it to verify
```sh
echo Domain: $(kubectl get secret --namespace sealedsecret-test user-creds -o jsonpath="{.data.domain}" | base64 -d)
echo Username: $(kubectl get secret --namespace sealedsecret-test user-creds -o jsonpath="{.data.username}" | base64 -d)
echo Password: $(kubectl get secret --namespace sealedsecret-test user-creds -o jsonpath="{.data.password}" | base64 -d)

```