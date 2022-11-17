resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16" # what ip address will be available in our network/ /16 is largest cidr block subnet
  enable_dns_support   = true          # enables this for vpc
  enable_dns_hostnames = true          # allows instances to have nice hostnames

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-vpc")
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    map("Name", "${local.prefix}-main")
  )
}