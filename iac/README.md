# Infrastructure on AWS

The following Terraform module can be used to deploy EC2 instances on *Localstack*, a cloud emulator for AWS. These EC2 instances can be used to build a Kubernets cluster. Beware: If running LocalStack **Community Edition**, there is no Docker container to access EC2 instances. Possible interactions are limited to the simulated AWS API responses provided by LocalStack.

## Requirements

Install [Docker Engine](https://docs.docker.com/engine/install) & LocalStack CLI:

```sh
curl --output localstack-cli-4.10.0-linux-amd64-onefile.tar.gz \
    --location https://github.com/localstack/localstack-cli/releases/download/v4.10.0/localstack-cli-4.10.0-linux-amd64-onefile.tar.gz

tar xvzf localstack-cli-4.10.0-linux-*-onefile.tar.gz -C /usr/local/bin
```

Install `python` & `uv` for [awslocal](https://github.com/localstack/awscli-local). As of now, `awslocal` only supports `v1`:

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh

mise use -g python@3.14 uv@latest
mise use -g pipx:awscli-local pipx:awscli
```

Install Terraform or OpenTofu (see available packages on you system) & [tflocal](https://docs.localstack.cloud/aws/integrations/infrastructure-as-code/terraform/#tflocal-wrapper-script):

```sh
mise use -g pipx:terraform-local
```

For OpenTofu compatibility, export the environment variable `TF_CMD=tofu`.

## Configure The Environment

Start the LocalStack environment & tag a dummy AMI for EC2 (we assume Ubuntu LTS):

```sh
localstack start -d

docker pull ubuntu:24.04
awslocal ec2 register-image --name "ubuntu-noble" --image-location "ubuntu:24.04"
awslocal ec2 create-tags --resources AMI_ID --tags Key=ec2_vm_manager,Value=docker
```

Fill-in required Terraform variables. You can generate the shared secret (token) with `openssl rand -hex 32`. The passphrase must be at least `16` characters long:

```hcl
passphrase    = "REDACTED"
cluster_name  = "CLUSTER_NAME"
cluster_token = "REDACTED"
```

Provision the infrastructure (we assume OpenTofu):

```sh
export TF_CMD=tofu

cd iac/

tflocal init -upgrade
tflocal plan -out=plan.out
tflocal apply plan.out
```

When you are done tear down the infrastructure and stop LocalStack:

```sh
tflocal destroy -auto-approve

localstack stop
```
