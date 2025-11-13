resource "aws_vpc" "this" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "this" {
  vpc_id          = aws_vpc.this.id
  cidr_block      = "10.0.1.0/24"
  ipv6_cidr_block = cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, 0)

  tags = {
    Name = "example-private-subnet"
  }
}

resource "aws_egress_only_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "example-eigw"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "example-private-rt"
  }
}

resource "aws_route" "ipv6_egress" {
  route_table_id              = aws_route_table.this.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.this.id
}
