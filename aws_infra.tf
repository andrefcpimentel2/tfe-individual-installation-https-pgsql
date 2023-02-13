provider "aws" {
  region  = var.region
}

data "aws_route53_zone" "fdqn" {
  zone_id = var.zone_id
}



resource "aws_vpc" "tfe_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name           = var.namespace
    owner          = var.owner
    created-by     = var.created-by
    sleep-at-night = var.sleep-at-night
    TTL            = var.TTL
  }
}

resource "aws_internet_gateway" "tfe_ig" {
  vpc_id = aws_vpc.tfe_vpc.id

  tags = {
    Name           = var.namespace
    owner          = var.owner
    created-by     = var.created-by
    sleep-at-night = var.sleep-at-night
    TTL            = var.TTL
  }
}

resource "aws_route_table" "tfe" {
  vpc_id = aws_vpc.tfe_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfe_ig.id
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "tfe_subnet" {
  count                   = length(var.cidr_blocks)
  vpc_id                  = aws_vpc.tfe_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = var.cidr_blocks[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name           = var.namespace
    owner          = var.owner
    created-by     = var.created-by
    sleep-at-night = var.sleep-at-night
    TTL            = var.TTL
  }
}

resource "aws_route_table_association" "tfe" {
  count          = length(var.cidr_blocks)
  route_table_id = aws_route_table.tfe.id
  subnet_id      = element(aws_subnet.tfe_subnet.*.id, count.index)
}

resource "aws_security_group" "tfe_sg" {
  name_prefix = var.namespace
  vpc_id      = aws_vpc.tfe_vpc.id

  # SSH access if host_access_ip has CIDR blocks
  dynamic "ingress" {
    for_each = local.host_access_ip
    content {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr_blocks = [ "${ingress.value}" ]
    }
  }

# HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #TFE Dashboard
  ingress {
    from_port   = 8800
    to_port     = 8800
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port   = 9870
  #   to_port     = 9880
  #   protocol    = "tcp"
  #   cidr_blocks = [aws_vpc.tfe_vpc.cidr_block]
  # }

  # ingress {
  #   from_port   = 23000
  #   to_port     = 23100
  #   protocol    = "tcp"
  #   cidr_blocks = [aws_vpc.tfe_vpc.cidr_block]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.namespace}-${var.owner}"
  public_key = file(var.ssh_public_key)
}

