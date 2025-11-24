# Bootstrap ArgoCD core

ArgoCD core does not handle the secret key for us. Instead, we can use a SealedSecret to provision the required key:

1. Install the cluster-side controller:
```sh
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
helm install sealed-secrets -n kube-system --set-string fullnameOverride=sealed-secrets-controller sealed-secrets/sealed-secrets
```
2. Install the client:
```sh
curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.33.1/kubeseal-0.33.1-linux-amd64.tar.gz"
tar -xvzf kubeseal-0.33.1-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```
3. (**OPTIONAL**) Generate the Secret manifest and the relative SealedSecret:
```sh
kubectl create namespace argocd

echo -n SUPER_SECURE_SECRET | kubectl create secret generic argocd-secret --dry-run=client --from-file=server.secretkey=/dev/stdin -o yaml >secret.yaml

kubeseal --format=yaml --secret-file=secret.yaml --sealed-secret-file=sealed-secret.yaml
rm secret.yaml
```
4. Install ArgoCD with kustomize:
```sh
kubectl apply -f sealed-secret.yaml

kubectl apply -k .
```
