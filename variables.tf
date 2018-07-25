variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "datadog_key" {}

variable "root" {
  default = "/home/ec2-user/app"
}

variable "key_pair_name" {
  default = "arquitectura"
}

variable "private_key_location" {
  default = "~/.ssh/arquitectura.pem"
}

variable "vpc_id" {
  default = "vpc-7563400d"
}

variable "ami_id" {
  default = "ami-1853ac65"
}

variable "node_version" {
  default = "8.11.2"
}
