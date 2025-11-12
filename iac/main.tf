locals {
  rke2_common = templatefile("${path.module}/templates/rke2-common.yaml.tftpl", {
    token = var.cluster_token
  })

  tags = {
    Role    = "master"
    Cluster = "${var.cluster_name}"
  }
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

  user_data = templatefile("${path.module}/templates/userdata-master.yaml.tftpl", {
    path_module  = path.module
    rke2_version = var.rke2_version
    rke2_common  = local.rke2_common

    rke2_master = templatefile("${path.module}/templates/rke2-master.yaml.tftpl", {
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

resource "aws_eip" "master" {
  count = var.master_count

  domain = "vpc"
  tags = merge(
    local.tags,
    {
      Name = "${var.cluster_name}-master-${count.index + 1}"
    }
  )
}

resource "aws_eip_association" "master" {
  count = var.master_count

  allocation_id = aws_eip.master[count.index].id
  instance_id   = aws_instance.k8s_master[count.index].id
}

resource "aws_instance" "k8s_worker" {
  count = var.worker_count

  ami           = data.aws_ami.ubuntu_noble.id
  instance_type = var.worker_instance
  key_name      = aws_key_pair.pub_key.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    //delete_on_termination = true
    encrypted = true
  }

  vpc_security_group_ids = [aws_security_group.k8s_worker.id]

  user_data = templatefile("${path.module}/templates/userdata-worker.yaml.tftpl", {
    rke2_version = var.rke2_version
    rke2_common  = local.rke2_common

    rke2_worker = templatefile("${path.module}/templates/rke2-worker.yaml.tftpl", {
      index     = "${count.index + 1}"
      master_ip = aws_eip.master[0].public_ip
    })
  })

  tags = merge(
    local.tags,
    {
      Name = "${var.cluster_name}-worker-${count.index + 1}"
    }
  )

  lifecycle {
    ignore_changes = [tags]
  }
}
