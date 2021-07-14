data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "infra-terraform-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "infra-igw"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    gateway_id  = aws_internet_gateway.gw.id
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "infra-public-route"
  }
}

resource "aws_default_route_table" "private_route" {

  default_route_table_id = aws_vpc.main.default_route_table_id
  route {
    nat_gateway_id = aws_nat_gateway.infra-nat-gateway[0].id
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "infra-private-route-table"
  }
}


resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id
  count=  length(var.private_subnets)
  route {
    gateway_id  = aws_nat_gateway.infra-nat-gateway[count.index].id
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "infra-private-route"
  }
}

resource "aws_subnet" "public_subnets_web" {
  count             = length(var.public_subnets)
  cidr_block        = var.public_subnets[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "infra-public-subnet.${count.index + 1}"
    "kubernetes.io/cluster/eks_infra" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}


# Private Subnet
resource "aws_subnet" "private_subnets_web" {
  count             = length(var.private_subnets)
  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "infra-private-subnet.${count.index + 1}"
    "kubernetes.io/cluster/eks_infra" = "owned"
    "kubernetes.io/role/internal-elb" = "1"
  }
}


# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_subnet_assoc" {
  count          = length(var.private_subnets)
  route_table_id = aws_route_table.private_route[count.index].id
  subnet_id      = aws_subnet.private_subnets_web.*.id[count.index]
  depends_on     = [aws_default_route_table.private_route, aws_subnet.private_subnets_web]
}

resource "aws_route_table_association" "instance" {
  count = length(var.public_subnets)
  subnet_id = aws_subnet.public_subnets_web.*.id[count.index]
  route_table_id = aws_route_table.public_route.id
  depends_on     = [aws_default_route_table.private_route, aws_subnet.private_subnets_web]
}

# Security Group Creation
resource "aws_security_group" "test_sg" {
  name   = "infra-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "http_inbound_access" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.test_sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# All OutBound Access
resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.test_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_eip" "infra-eip" {
  count = 2
  vpc = true
}

resource "aws_nat_gateway" "infra-nat-gateway" {
  count = 2
  allocation_id = aws_eip.infra-eip[count.index].id
  subnet_id     = aws_subnet.public_subnets_web[count.index].id
}
