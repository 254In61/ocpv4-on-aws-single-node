// VPC

resource "aws_vpc" "cluster-vpc" {
  cidr_block            = "${var.vpc_cidr}"
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags                  = {
     "Name"             = "${var.cluster_name}-vpc"
  }
}

// IGW

resource "aws_internet_gateway" "igw" {
  // Creates IGW and attaches to the vpc
  vpc_id = aws_vpc.cluster-vpc.id

  tags                  = {
     "Name"             = "${var.cluster_name}-igw"
  }
}