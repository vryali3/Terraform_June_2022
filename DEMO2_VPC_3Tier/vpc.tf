resource "aws_vpc" "ThreetierVPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_subnet" "subnets" {
  vpc_id   = aws_vpc.ThreetierVPC.id
  for_each = {public_subnet_for_myvpc:"10.0.3.0/24", private_subnet_for_myvpc:"10.0.4.0/24"}
  cidr_block = each.value

  tags = {
    Name = each.key
  }
}


#count or for-each - meta arguments

/*

"10.0.1.0/24"
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.ThreetierVPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "public_subnet_for_myvpc"
  }
}
*/

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ThreetierVPC.id
  tags = {
    Name = "public-rt-ThreetierVPC"
  }
}

resource "aws_default_route_table" "private_rt" {
  default_route_table_id = aws_vpc.ThreetierVPC.default_route_table_id
  tags = {
    Name = "private-rt-ThreetierVPC"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ThreetierVPC.id

  tags = {
    Name = "igw-threetiervpc"
  }
}



resource "aws_route_table_association" "public_association" {
  subnet_id      = element([for x in aws_subnet.subnets: x.id],0)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = element([for x in aws_subnet.subnets: x.id],1)
  route_table_id = aws_default_route_table.private_rt.id
}
