data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_subnet_ids" "nrw_private_subnets" {
  vpc_id = aws_vpc.nrw.id

  tags = {
    "subnet_type" = "private"
  }
}


resource "aws_vpc" "nrw" {
  cidr_block           = var.network_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags.env, {
    "Name" = "nrw-${terraform.workspace}-ng"
  })
}

resource "aws_subnet" "nrw_public_subnets" {
  for_each = toset(data.aws_availability_zones.azs.names)

  vpc_id            = aws_vpc.nrw.id
  availability_zone = each.key
  cidr_block = cidrsubnet(
    aws_vpc.nrw.cidr_block,
    8,
    index(data.aws_availability_zones.azs.names, each.key)
  )
  map_public_ip_on_launch = true

  tags = merge(local.tags.env, {
    "Name"         = "${terraform.workspace}-public"
    "subnet_type"  = "public"
    "subnet_index" = index(data.aws_availability_zones.azs.names, each.key)
  })
}

resource "aws_subnet" "nrw_private_subnets" {
  for_each = toset(data.aws_availability_zones.azs.names)

  vpc_id            = aws_vpc.nrw.id
  availability_zone = each.key
  cidr_block = cidrsubnet(
    aws_vpc.nrw.cidr_block,
    8,
    20 + index(data.aws_availability_zones.azs.names, each.key)
  )
  map_public_ip_on_launch = false

  tags = merge(local.tags.env, {
    "Name"         = "${terraform.workspace}-private"
    "subnet_index" = index(data.aws_availability_zones.azs.names, each.key)
    "subnet_type"  = "private"
  })
}


resource "aws_internet_gateway" "nrw_igw" {
  vpc_id = aws_vpc.nrw.id

  tags = local.tags.env
}

# ================= Public routes =================
resource "aws_route_table" "nrw_public_rt" {
  vpc_id = aws_vpc.nrw.id

  tags = merge(local.tags.env, {
    "Name" = "${terraform.workspace}-public-rt"
  })
}

resource "aws_route" "nrw_public-default-route" {
  route_table_id         = aws_route_table.nrw_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.nrw_igw.id
}

resource "aws_route_table_association" "nrw_main_rt-association" {
  for_each = aws_subnet.nrw_public_subnets

  route_table_id = aws_route_table.nrw_public_rt.id
  subnet_id      = each.value.id
}
