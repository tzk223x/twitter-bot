resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.1.0/25"
  availability_zone = "us-west-2c"

  tags = {
    "Name" = "public | us-west-2c"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.2.0/25"
  availability_zone = "us-west-2c"

  tags = {
    "Name" = "private | us-west-2c"
  }
}

resource "aws_subnet" "public_d" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.1.128/25"
  availability_zone = "us-west-2d"

  tags = {
    "Name" = "public | us-west-2d"
  }
}

resource "aws_subnet" "private_d" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.2.128/25"
  availability_zone = "us-west-2d"

  tags = {
    "Name" = "private | us-west-2d"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    "Name" = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    "Name" = "private"
  }
}

resource "aws_route_table_association" "public_c_subnet" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_c_subnet" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_d_subnet" {
  subnet_id      = aws_subnet.public_d.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_d_subnet" {
  subnet_id      = aws_subnet.private_d.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
}

resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public_c.id
  allocation_id = aws_eip.nat.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_security_group" "no_ingress" {
  name        = "no_ingress"
  description = "No ingress traffic"
  vpc_id      = aws_vpc.app_vpc.id
}

resource "aws_security_group" "egress_all" {
  name        = "egress-all"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
