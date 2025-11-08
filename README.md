# Kubernetes Homelab Setup

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
mise use -g pipx:awscli-local[ver1] pipx:awscli
```

Install Terraform or OpenTofu (see available packages on you system) & [tflocal](https://docs.localstack.cloud/aws/integrations/infrastructure-as-code/terraform/#tflocal-wrapper-script). For OpenTofu compatibility, export the environment variable `TF_CMD=tofu`.

## Configure The Environment

Boot the LocalStack environment & provision the infrastructure (we assume OpenTofu):

```sh
localstack start -d

export TF_CMD=tofu

cd iac/
tflocal init -upgrade
tflocal plan -out=plan.out
tflocal apply
```
