variable "default_tags" {
    type = "map"
    
    default = {
        responsible: "jibanezn",
        project: "jibanezn-rampup"
    }
    
}

variable "jenkins_tags" {
    type = "map"
    
    default = {
        Name: "Jenkins_server",
        responsible: "jibanezn",
        project: "jibanezn-rampup"
    }
    
}

variable "subnet_cidrs_public" {
    description = "Subnet CIDR's for public subnets"
    default = ["10.0.1.0/24", "10.0.4.0/24"]
    type = "list"
}

variable "subnet_cidrs_private" {
    description = "Subnet CIDR's for private subnets"
    default = ["10.0.2.0/24", "10.0.3.0/24"]
    type = "list"
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default = ["us-east-2a", "us-east-2b"]
  type = "list"
}