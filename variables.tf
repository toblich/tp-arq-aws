variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "us-east-1"
}

variable datadog_key {}

variable "root" {
  default = "~/app"
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
