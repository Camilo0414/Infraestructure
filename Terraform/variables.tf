variable "default_tags" {
  type = map(any)

  default = {
    responsible = "jibanezn"
    project     = "jibanezn-rampup"
  }

}

variable "jenkins_tags" {
  type = map(any)

  default = {
    Name        = "Jenkins_server"
    responsible = "jibanezn"
    project     = "jibanezn-rampup"
  }

}

variable "instance_tags" {
  type = list(any)

  default = [{
    key                 = "responsible"
    value               = "jibanezn"
    propagate_at_launch = true
    },
    {
      key                 = "project"
      value               = "jibanezn-rampup"
      propagate_at_launch = true
  }]

}

variable "subnet_cidrs_public" {
  type        = list(any)
  description = "Subnet CIDR's for public subnets"
  default     = ["10.0.1.0/24", "10.0.4.0/24"]

}

variable "subnet_cidrs_private" {
  type        = list(any)
  description = "Subnet CIDR's for private subnets"
  default     = ["10.0.2.0/24", "10.0.3.0/24"]

}

variable "availability_zones" {
  type        = list(any)
  description = "AZs in this region to use"
  default     = ["us-west-1a", "us-west-1c"]
}

variable "nacl_public_ports" {
  type        = list(number)
  description = "list of ingress ports for public subnet"
  default     = [22, 80, 443, 3030]
}
variable "nacl_private_ports" {
  type        = list(number)
  description = "list of ingress ports for private subnet"
  default     = [22, 3000]
}

variable "image_id" {
  type        = string
  description = "image id of the instances"
  default     = "ami-0b2ca94b5b49e0132"
}

variable "instance_type" {
  type        = string
  description = "instance type of the instances"
  default     = "t2.micro"
}