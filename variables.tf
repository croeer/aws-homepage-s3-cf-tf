variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central1"
}
