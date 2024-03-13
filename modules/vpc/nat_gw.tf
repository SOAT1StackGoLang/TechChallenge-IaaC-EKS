# Create Elastic IP
resource "aws_eip" "main" {
  vpc = true
}

# Create NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "NAT Gateway for Custom Kubernetes Cluster"
  }
}

## Add route to route table
#resource "aws_route" "private" {
#  route_table_id            = aws_vpc.custom_vpc.default_route_table_id
#  destination_cidr_block    = "0.0.0.0/0"
#  nat_gateway_id = aws_nat_gateway.main.id
#}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}"
  }
}


# Route table and subnet associations
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}