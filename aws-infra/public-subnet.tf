// ==== SUBNETS

// Create subnet 

resource "aws_subnet" "public-subnet" {
 vpc_id               = aws_vpc.cluster-vpc.id
 cidr_block           = "${var.az.pub-sub-cidr}"
 availability_zone    = "${var.az.name}"
 
 tags = {
   "Name"             = "${var.cluster_name}-public-subnet"
 }
}

// Routing of public subnets to the Internet
// LOGIC : Public subnet ==> IGW ==> Internet

// Build a public RT with default route attached.

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.cluster-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags         = {
      "Name"   = "${var.cluster_name}-public-rt"
  }
}

// Associate public subnet to public rt

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}
