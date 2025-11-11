locals {
  tags = {
    Role    = "master"
    Cluster = "${var.cluster_name}"
  }
}

locals {
  rke2_common = templatefile("${path.module}/templates/rke2-common.yaml.tftpl", {
    token = var.cluster_token
  })
}

data "aws_ami" "ubuntu_noble" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-5e654f5f6ea403716"] // Ubuntu LTS 24.04
  }
}

resource "aws_key_pair" "pub_key" {
  key_name   = "pub-key"
  public_key = file(pathexpand(var.pub_key_path))
}

resource "aws_instance" "k8s_master" {
  count = var.master_count

  ami           = data.aws_ami.ubuntu_noble.id
  instance_type = var.master_instance
  key_name      = aws_key_pair.pub_key.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    //delete_on_termination = true
    encrypted = true
  }

  vpc_security_group_ids = [aws_security_group.k8s_master.id]

  user_data = templatefile("${path.module}/templates/userdata.yaml.tftpl", {
    rke2_common = local.rke2_common

    rke2_node = templatefile("${path.module}/templates/rke2-master.yaml.tftpl", {
      index = "${count.index + 1}"
    })
  })

  tags = merge(
    local.tags,
    {
      Name = "${var.cluster_name}-master-${count.index + 1}"
    }
  )

  lifecycle {
    ignore_changes = [tags]
  }
}
