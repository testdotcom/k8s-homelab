# Bootstrap K8s Cluster

Before being able to operate the K8s cluster, we have some manual work to do:

- Install the ArgoCD controller, refer to `argocd-install/`
- (Recommended) Enable Gateway API support

On November 2025, the Ingress NGINX has been [officially retired](https://www.kubernetes.dev/blog/2025/11/12/ingress-nginx-retirement), and the RKE2 addon is disabled on this project. The recommended way is to enable the Gateway API; Cilium stable release `1.8` supports up to [Gateway Profile 1.3](https://gateway-api.sigs.k8s.io/implementations/v1.3):

If you provisioned a RKE2 cluster, uncomment `cilium.enable-gateway-api` from `/etc/rancher/rke2/config.yaml.d/master.yaml` and restart the service:

```sh
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml

systemctl restart rke2-server.service
```

Instead for a minikube node, disable the default CNI and then install cilium CNI:

```sh
minikube start --cni=false \
    --extra-config=kubeadm.skip-phases=addon/kube-proxy \
    --addons=metrics-server

kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml

API_SERVER_IP=$(minikube ip)
API_SERVER_PORT=8443	        # Minikube default

helm install cilium cilium/cilium --namespace kube-system \
	--set k8sServiceHost=${API_SERVER_IP} \
	--set k8sServicePort=${API_SERVER_PORT} \
	--set kubeProxyReplacement=true \
	--set gatewayAPI.enabled=true \
	--set l2announcements.enabled=true \
	--set operator.replicas=1

kubectl -n kube-system rollout status ds/cilium
```
