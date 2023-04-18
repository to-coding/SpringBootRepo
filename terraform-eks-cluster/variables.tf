variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
    description = "default cluster name"
    type = string
    default = "onbeach-test-eks"
}

variable "vpc_name" {
    description = "default vpc name"
    type = string
    default = "onbeach-test-vpc"
}
