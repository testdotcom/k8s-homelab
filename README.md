# Kubernetes Homelab Setup

The following project is a blueprint for provisioning a self-hosted Kubernetes cluster. Please refer to each subfolder README:

- **argocd-apps**: Implement GitOps by following the *app-of-apps* pattern
- **argocd-install**: Deploy ArgoCD core on the cluster, for Continuous Deployment
- **iac**: A Terraform module to deploy EC2 instances on Localstack, a cloud emulator for AWS

For local development, you can use minikube (instead of Terraform/Localstack) to configure a single master node. We assume RKE2 as Kubernetes distro with Cilium CNI - please refer to the `iac/ec2_cluster` submodule.

## Enable Kubernetes Gateway APIs

On November 2025, the Ingress NGINX has been [officially retired](https://www.kubernetes.dev/blog/2025/11/12/ingress-nginx-retirement), and the RKE2 addon is disabled on this project. The recommended way is to enable the Gateway API; Cilium stable release `1.8` supports up to [Gateway Profile 1.3](https://gateway-api.sigs.k8s.io/implementations/v1.3):

```sh
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml

# Uncomment cilium.enable-gateway-api from /etc/rancher/rke2/config.yaml.d/master.yaml

systemctl restart rke2-server.service
```
