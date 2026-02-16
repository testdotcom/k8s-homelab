# Kubernetes Homelab Setup

[![CICD pipeline](https://github.com/testdotcom/k8s-homelab/actions/workflows/cicd.yaml/badge.svg)](https://github.com/testdotcom/k8s-homelab/actions/workflows/cicd.yaml)

The following project is a blueprint for provisioning a self-hosted Kubernetes cluster. Please refer to each subfolder README:

- **argocd-apps**: Implement GitOps by following the *app-of-apps* pattern
- **argocd-install**: Deploy ArgoCD core on the cluster, for Continuous Deployment
- **iac**: A Terraform module to deploy EC2 instances on Localstack, a cloud emulator for AWS

For local development, you can use minikube (instead of Terraform/Localstack) to configure a single master node; or refer to the `iac/ec2_cluster` submodule.
