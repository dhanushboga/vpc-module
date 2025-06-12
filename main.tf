resource "aws_vpc" "main" {
  cidr_block       = var.VPC_CIDR
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy = "default"

  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
       Name = local.resource_name
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
       Name = local.resource_name
    }
  )
}

# expense-dev-public-us-east-1a
# expense-dev-public-us-east-1b
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  count = length(var.public_subnet_cidr)
  availability_zone = local.az_names[count.index]
  cidr_block = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    var.public_subnet_tags,
    {
       Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }
  )
}

# expense-dev-private-us-east-1a
# expense-dev-private-us-east-1b
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  count = length(var.private_subnet_cidr)
  availability_zone = local.az_names[count.index]
  cidr_block = var.private_subnet_cidr[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_tags,
    {
       Name = "${local.resource_name}-private-${local.az_names[count.index]}"
    }
  )
}

# expense-dev-database-us-east-1a
# expense-dev-database-us-east-1b
resource "aws_subnet" "database_subnet" {
  vpc_id     = aws_vpc.main.id
  count = length(var.database_subnet_cidr)
  availability_zone = local.az_names[count.index]
  cidr_block = var.database_subnet_cidr[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
    {
       Name = "${local.resource_name}-database-${local.az_names[count.index]}"
    }
  )
}

resource "aws_eip" "elastic_ip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
    {
       Name = "${local.resource_name}"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_tags,
    {
       Name = "${local.resource_name}-public"
    }
  )
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_route_tags,
    {
       Name = "${local.resource_name}-private"
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_route_tags,
    {
       Name = "${local.resource_name}-database"
    }
  )
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}


resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr)
  subnet_id      = aws_subnet.database_subnet[count.index].id
  route_table_id = aws_route_table.database.id
}


# DB Subnet group for RDS
resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database_subnet[*].id

  tags = merge(
    var.common_tags,
    var.db_subnet_group_tags,
    {
        Name = local.resource_name
    }
  )
}