variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "default cluster name"
  type        = string
  default     = "onbeach-test-eks"
}

variable "vpc_name" {
  description = "default vpc name"
  type        = string
  default     = "onbeach-test-vpc"
}

variable "ecr_name" {
  description = "name of the ECR registry"
  type        = string
  default     = "onbeach_ecr"
}

variable "image_mutability" {
  description = "provide image mutability"
  type        = string
  default     = "MUTABLE"
}

variable "encrypt_type" {
  description = "provide type of encryption here"
  type        = string
  default     = "KMS"
}

variable "tags" {
  description = "the key-value maps for tagging"
  type        = map(string)
  default     = {}
}
