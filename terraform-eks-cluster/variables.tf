variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "default cluster name"
  type        = string
  default     = "beach-eks"
}

variable "vpc_name" {
  description = "default vpc name"
  type        = string
  default     = "beach-vpc"
}

variable "ecr_name" {
  description = "name of the ECR registry"
  type        = string
  default     = "beach_ecr"
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

variable "node_1_of_ng1" {
  description = "node 1 of ng1"
  type = string
  default = "beach_node1"
}

variable "node_1_of_ng2" {
  description = "node 1 of ng2"
  type = string
  default = "beach_node2"
}
