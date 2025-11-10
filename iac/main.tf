locals {
  tags = {
    Role    = "master"
    Cluster = "${var.cluster_name}"
  }
}

data "aws_ami" "opensuse_leap" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-5e654f5f6ea403716"] // Ubuntu Noble LTS 24.04
  }
}

resource "aws_key_pair" "pub_key" {
  key_name   = "pub-key"
  public_key = file(pathexpand(var.pub_key_path))
}

resource "aws_instance" "k8s_master" {
  count = var.master_count

  ami           = data.aws_ami.opensuse_leap.id
  instance_type = var.master_instance
  key_name      = aws_key_pair.pub_key.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    //delete_on_termination = true
    encrypted = true
  }

  vpc_security_group_ids = [aws_security_group.k8s_master.id]

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
