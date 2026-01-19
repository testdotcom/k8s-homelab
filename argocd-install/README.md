# Bootstrap ArgoCD core

ArgoCD **Core** does not handle the secret key for us. Instead, we can use a `SealedSecret` to provision the required key:

1. Install the cluster-side controller:
```sh
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
helm install sealed-secrets --namespace=kube-system --set-string fullnameOverride=sealed-secrets-controller sealed-secrets/sealed-secrets
```
2. Install the client:
```sh
curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.34.0/kubeseal-0.34.0-linux-amd64.tar.gz"
tar -xvzf kubeseal-0.34.0-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```
3. Backup the private key. **DO NOT** commit the key on git
```sh
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > sealedsecret-private-key.yaml
```
4. (**OPTIONAL**) Restore the private key
```sh
kubectl apply -f sealedsecret-private-key.yaml
```
5. (**OPTIONAL**) Generate the Secret manifest and the relative SealedSecret:
```sh
echo -n SUPER_SECURE_SECRET | kubectl create secret generic argocd-secret --dry-run=client --from-file=server.secretkey=/dev/stdin -o yaml >secret.yaml

kubeseal --format=yaml --namespace=argocd --secret-file=secret.yaml --sealed-secret-file=sealed-secret.yaml
rm secret.yaml

kubectl apply -f argocd-ns.yaml -f sealed-secret.yaml
```
6. Install `argocd-core` with kustomize:
```sh
kubectl apply --server-side --kustomize=argocd-install/
```

It is still possible to use ArgoCD CLI even when running ArgoCD Core: the CLI will spawn a local API server process to handle CLI command:

```sh
kubectl config set-context --current --namespace=argocd
argocd login --core

# OPTIONAL: Run the web UI locally
argocd admin dashboard --namespace=argocd
```
