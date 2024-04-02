// 1. INTERNET GATEWAY BUILD

resource "aws_internet_gateway" "igw" {
  // Creates IGW and attaches to the vpc
  vpc_id = aws_vpc.cluster_vpc.id

  tags                  = {
     "Name"             = "${var.cluster_name}-igw"
  }
}

// 2. PUBLIC SUBNETS ROUTING

// 2.1 : Create rt and attach default route

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.cluster_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags                  = {
     "kubernetes.io/cluster/${var.infra_name}" = "owned"
     "Name" = "${var.infra_name}-public"
  }
}

// 2.2 : Associate public subnets to public rt

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.public-subnet-3.id
  route_table_id = aws_route_table.public-rt.id
}

// 3. PRIVATE SUBNETS ROUTING 

// 3.1 : Route Private Subnet 1 / Availability zone a 

// 3.1.1 : Obtain EIP 

resource "aws_eip" "eip_1" {
  vpc = true  // Boolean if the EIP is in a VPC or not. Defaults to true unless the region supports EC2-Classic.
  depends_on = [aws_internet_gateway.igw] // EIP may require IGW to exist prior to association.

  tags                  = {
     "kubernetes.io/cluster/${var.infra_name}" = "owned"
     "Name" = "${var.infra_name}-eip-${var.a.az_name}"
  }

}


// 3.1.2 : Create nat gateway

resource "aws_nat_gateway" "ngw_1" {
  // connectivity_type = "public"  // Connectivity type for the gateway. Valid values are private and public. Defaults to public.
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.private-subnet-1.id

  tags                  = {
     "kubernetes.io/cluster/${var.infra_name}" = "owned"
     "Name" = "${var.infra_name}-nat-${var.a.az_name}"
  }

  // To ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


// 3.1.3 : Create private route table 

resource "aws_route_table" "private-rt1" {
  vpc_id = aws_vpc.cluster_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_1.id
  }

  tags                  = {
     "kubernetes.io/cluster/${var.infra_name}" = "owned"
     "Name" = "${var.infra_name}-private-$${var.a.az_name}"
  }
}

// 3.1.4 : Associate private subnet to rt

resource "aws_route_table_association" "priv-rta-1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-rt1.id
}

// 3.2 : Route Private Subnet 2 / availability zone b

// 3.2.1 : Obtain EIP 

resource "aws_eip" "eip_2" {
  vpc = true  // Boolean if the EIP is in a VPC or not. Defaults to true unless the region supports EC2-Classic.
  depends_on = [aws_internet_gateway.igw] // EIP may require IGW to exist prior to association.

  tags                  = {
     "kubernetes.io/cluster/${var.infra_name}" = "owned"
     "Name" = "${var.infra_name}-eip-${var.b.az_name}"
  }

}




// 3.2.3 : Create private route table 

resource "aws_route_table" "private-rt2" {
  vpc_id = aws_vpc.cluster_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_2.id
  }

  tags                  = {
     "kubernetes.io/cluster/${var.infra_name}" = "owned"
     "Name"= "${var.infra_name}-private-${var.b.az_name}"
  }
}

// 3.2.4 : Associate private subnet to rt

resource "aws_route_table_association" "priv-rta-2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-rt2.id
}


// 3.3 : Route Private Subnet 3 / availability zone c

// 3.3.1 : Obtain EIP 

resource "aws_eip" "eip_3" {
  vpc = true  // Boolean if the EIP is in a VPC or not. Defaults to true unless the region supports EC2-Classic.
  depends_on = [aws_internet_gateway.igw] // EIP may require IGW to exist prior to association.

  tags                  = {
     "kubernetes.io/cluster/${var.infra_name}" = "owned"
     "Name" = "${var.infra_name}-eip-${var.c.az_name}"
  }

}


// 3.3.2 : Create nat gateway

resource "aws_nat_gateway" "ngw_3" {
  // connectivity_type = "public"  // Connectivity type for the gateway. Valid values are private and public. Defaults to public.
  allocation_id = aws_eip.eip_3.id
  subnet_id     = aws_subnet.private-subnet-3.id

  tags                  = {
     "kubernetes.io/cluster/${var.infra_name}" = "owned"
     "Name" = "${var.infra_name}-nat-${var.c.az_name}"
  }

  // To ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


// 3.3.3 : Create private route table 

resource "aws_route_table" "private-rt3" {
  vpc_id = aws_vpc.cluster_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw_3.id
  }

  tags                  = {
     "kubernetes.io/cluster/${var.infra_name}" = "owned"
     "Name" = "${var.infra_name}-private-${var.c.az_name}"
  }
}

// 3.3.4 : Associate private subnet to rt

resource "aws_route_table_association" "priv-rta-3" {
  subnet_id      = aws_subnet.private-subnet-3.id
  route_table_id = aws_route_table.private-rt3.id
}

// 4. S3 VPCE

/*
- The VPCE is a Gateway that allows access to the rest of AWS Cloud services without transiting 
  through NGW or IGW.
- The created VPCE routes to S3
- It is less costly and traffic never leaves AWS Cloud.
- AWS has prefixes within which the AWS services are hosted.
- All the route table created are added to this GW.
*/

// 4.1 : Create s3 vpce

resource "aws_vpc_endpoint" "s3-vpce" {
  vpc_id            = aws_vpc.cluster_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  // vpc_endpoint_type = "Gateway" Defaults to Gateway.
  
  tags                  = {
     "kubernetes.io/cluster/${var.infra_name}" = "owned"
  }

}

// 4.2 : vpce endpoint policy 
resource "aws_vpc_endpoint_policy" "s3-vpce-policy" {
  vpc_endpoint_id = aws_vpc_endpoint.s3-vpce.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3VPCEAllowAll",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "*",
        "Resource" : "*"
      }
    ]
  })
}

// 4.3 : VPC Endpoint Route Table Association

// 4.3.1  : Association to public route table

resource "aws_vpc_endpoint_route_table_association" "vpce-rta-public" {
  route_table_id  = aws_route_table.public-rt.id
  vpc_endpoint_id = aws_vpc_endpoint.s3-vpce.id
}

// 4.3.2 : Association to private route tables 1,2 and 3

resource "aws_vpc_endpoint_route_table_association" "vpce-rta-private-1" {
  route_table_id  = aws_route_table.private-rt1.id
  vpc_endpoint_id = aws_vpc_endpoint.s3-vpce.id
}

resource "aws_vpc_endpoint_route_table_association" "vpce-rta-private-2" {
  route_table_id  = aws_route_table.private-rt2.id
  vpc_endpoint_id = aws_vpc_endpoint.s3-vpce.id
}

resource "aws_vpc_endpoint_route_table_association" "vpce-rta-private-3" {
  route_table_id  = aws_route_table.private-rt3.id
  vpc_endpoint_id = aws_vpc_endpoint.s3-vpce.id
}

