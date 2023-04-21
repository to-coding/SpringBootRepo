variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}
variable "ecr_name" {
  description = "name of the ECR registry"
  type        = string
  default     = "beach-hyq"
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