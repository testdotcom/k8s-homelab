resource "aws_security_group" "k8s_master" {
  name_prefix = "k8s-master-"
  description = "Security group for RKE2 Kubernetes master nodes"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.k8s_master.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "allow-all-outbound"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.k8s_master.id
  description       = "SSH access"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "k8s-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "k8s_api" {
  security_group_id = aws_security_group.k8s_master.id
  description       = "Kubernetes API server"
  from_port         = 6443
  to_port           = 6443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "k8s-api"
  }
}

resource "aws_vpc_security_group_ingress_rule" "etcd" {
  security_group_id = aws_security_group.k8s_master.id
  description       = "etcd client, peer, and metrics"
  from_port         = 2379
  to_port           = 2381
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "etcd-client"
  }
}

resource "aws_vpc_security_group_ingress_rule" "kubelet" {
  security_group_id = aws_security_group.k8s_master.id
  description       = "kubelet metrics"
  from_port         = 10250
  to_port           = 10250
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "kubelet-api"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodeport_tcp" {
  security_group_id = aws_security_group.k8s_master.id
  description       = "NodePort services range (TCP)"
  from_port         = 30000
  to_port           = 32767
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "nodeport-tcp"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nodeport_udp" {
  security_group_id = aws_security_group.k8s_master.id
  description       = "NodePort services range (UDP)"
  from_port         = 30000
  to_port           = 32767
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "nodeport-udp"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rke2_supervisor" {
  security_group_id = aws_security_group.k8s_master.id
  description       = "RKE2 supervisor API"
  from_port         = 9345
  to_port           = 9345
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "rke2-supervisor"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cilium_health_checks" {
  security_group_id = aws_security_group.k8s_master.id
  description       = "cilium health checks"
  from_port         = 4240
  to_port           = 4240
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "kube-scheduler"
  }
}

resource "aws_vpc_security_group_ingress_rule" "flannel_vxlan" {
  security_group_id = aws_security_group.k8s_master.id
  description       = "Flannel VXLAN"
  from_port         = 8472
  to_port           = 8472
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "flannel-vxlan"
  }
}
