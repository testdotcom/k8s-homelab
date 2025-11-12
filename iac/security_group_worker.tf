resource "aws_security_group" "k8s_worker" {
  name_prefix = "k8s-worker-"
  description = "Security group for RKE2 worker nodes"
}

resource "aws_vpc_security_group_egress_rule" "worker_allow_outbound" {
  security_group_id = aws_security_group.k8s_worker.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "allow-all-outbound"
  }
}

resource "aws_vpc_security_group_ingress_rule" "worker_ssh" {
  security_group_id = aws_security_group.k8s_worker.id
  description       = "SSH access"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "k8s-ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "worker_kubelet_metrics" {
  security_group_id = aws_security_group.k8s_master.id
  description       = "kubelet metrics"
  from_port         = 10250
  to_port           = 10250
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "kubelet-metrics"
  }
}

resource "aws_vpc_security_group_ingress_rule" "worker_nodeport_tcp" {
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

resource "aws_vpc_security_group_ingress_rule" "worker_nodeport_udp" {
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

resource "aws_vpc_security_group_ingress_rule" "worker_cilium_health_checks" {
  security_group_id = aws_security_group.k8s_worker.id
  description       = "cilium health checks"
  from_port         = 4240
  to_port           = 4240
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "kube-scheduler"
  }
}

resource "aws_vpc_security_group_ingress_rule" "worker_flannel_vxlan" {
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
