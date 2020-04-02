data "http" "myipaddr" {
    url = "http://ipv4.icanhazip.com"
}

locals {
   host_access_ip = ["${chomp(data.http.myipaddr.body)}/32"]
}

variable "region" {
  description = "The region to create resources."
  default     = "eu-west-2"
}

variable "namespace" {
  description = <<EOH
this is the differantiates different deployment on the same subscription, every cluster should have a different value
EOH
  default = "andretfe"
}



variable "owner" {
description = "IAM user responsible for lifecycle of cloud resources used for training"
default = "andre"
}

variable "created-by" {
description = "Tag used to identify resources created programmatically by Terraform"
default = "Terraform"
}

variable "sleep-at-night" {
description = "Tag used by reaper to identify resources that can be shutdown at night"
default = true
}

variable "TTL" {
description = "Hours after which resource expires, used by reaper. Do not use any unit. -1 is infinite."
default = "240"
}

variable "vpc_cidr_block" {
description = "The top-level CIDR block for the VPC."
default = "10.1.0.0/16"
}

variable "cidr_blocks" {
description = "The CIDR blocks to create the workstations in."
default = ["10.1.1.0/24", "10.1.2.0/24"]
}


variable "instance_type_worker" {
description = "The type(size) of data servers (consul, nomad, etc)."
default = "m5.large"
}

# variable "host_access_ip" {
#   description = "CIDR blocks allowed to connect via SSH on port 22"
#   default = []
# }

variable "ssh_public_key" {
    description = "The contents of the SSH public key to use for connecting to the cluster."
    default = "~/.ssh/id_rsa.pub"
}

variable "zone_id" {
  description = "The CIDR blocks to create the workstations in."
  default     = ""
}

variable "ca_key_algorithm" {
default = ""
}

variable "ca_private_key_pem" {
default = ""
}

variable "ca_cert_pem" {
default = ""
}

variable "ami" {
  default = "ami-6b3fd60c"
}

variable "ca_cert_file" {
  default = "cert.pem"
}

variable "ca_key_file" {
  default = "key.pem"
}

variable "license_file" {
  default = "hashicorp-internal---se.rli"
}


# variable "database_name" {}
# variable "database_username" {}
# variable "database_pwd" {}
# variable "database_storage" {}
# variable "database_instance_class" {}
# variable "database_multi_az" {}


