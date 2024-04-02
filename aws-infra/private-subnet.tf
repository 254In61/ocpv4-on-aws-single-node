// Create private subnet

resource "aws_subnet" "private-subnet" {
 vpc_id               = aws_vpc.cluster-vpc.id
 cidr_block           = "${var.az.priv-sub-cidr}"
 availability_zone    = "${var.az.name}"
 
 tags = {
   "Name"             = "${var.cluster_name}-private-subnet"
 }
}

// Routing of Private subnets to the internet.
// Private subnet ==> NAT GW (attached EIP) ==> IGW ==> Internet

// Obtain EIP 

resource "aws_eip" "eip" {
  vpc                  = true  // Boolean if the EIP is in a VPC or not. Defaults to true unless the region supports EC2-Classic.
  depends_on           = [aws_internet_gateway.igw] // EIP may require IGW to exist prior to association.

  tags                 = {
     "Name"            = "${var.cluster_name}-eip"
  }
}

// Create NAT gateway and assign public side the eip above

resource "aws_nat_gateway" "ngw" {
  // connectivity_type = "public"  // Connectivity type for the gateway. Valid values are private and public. Defaults to public.
  allocation_id        = aws_eip.eip.id
  subnet_id            = aws_subnet.private-subnet.id

  tags                 = {
     "Name"            = "${var.cluster_name}-ngw"
  }

  // To ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
  depends_on           = [aws_internet_gateway.igw]
}


// Build private Route Table and route all to NGW 

resource "aws_route_table" "private-rt" {
  vpc_id              = aws_vpc.cluster-vpc.id

  route {
    cidr_block        = "0.0.0.0/0"
    gateway_id        = aws_nat_gateway.ngw.id
  }

  tags                = {
     "Name"           = "${var.cluster_name}-private-rt"
  }
}

// Associate private subnet to RT

resource "aws_route_table_association" "priv-rt" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

