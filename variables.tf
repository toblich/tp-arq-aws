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
  default = "vpc-d7cec3ac"
}

variable "ami_id" {
  default = "ami-14c5486b"
}

variable "node_version" {
  default = "8.11.1"
}

variable "src_location" {
  default = "https://s3.amazonaws.com/tp-arquitecturas/src.zip"
}
