// YES!! LOTS OF REPITITION HERE!! Terragrunt is the magic bullet!

variable "cluster_name"{
  description  = "Chose cluster name"
  type         = string
}

// VPC
variable "vpc_cidr"{
  description  = "VPC cidr"
  type         = string
}

// SUBNETS
// Map defined in terrafor.tfvars file

variable "az"{
  description = "Availability zone"
  type        = map
}
