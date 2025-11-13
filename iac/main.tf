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

  associate_public_ip_address = false
  subnet_id                   = aws_subnet.this.id
  vpc_security_group_ids      = [aws_security_group.k8s_master.id]

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    //delete_on_termination = true
    encrypted = true
  }

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

resource "aws_instance" "k8s_worker" {
  count = var.worker_count

  ami           = data.aws_ami.ubuntu_noble.id
  instance_type = var.worker_instance
  key_name      = aws_key_pair.pub_key.key_name

  associate_public_ip_address = false
  subnet_id                   = aws_subnet.this.id
  vpc_security_group_ids      = [aws_security_group.k8s_worker.id]

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    //delete_on_termination = true
    encrypted = true
  }

  user_data = templatefile("${path.module}/templates/userdata-worker.yaml.tftpl", {
    rke2_version = var.rke2_version
    rke2_common  = local.rke2_common

    rke2_worker = templatefile("${path.module}/templates/rke2-worker.yaml.tftpl", {
      index     = "${count.index + 1}"
      master_ip = aws_instance.k8s_master[0].private_ip
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
