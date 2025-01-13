variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central1"
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for the API Gateway custom domain (us-east-1)."
  type        = string
  default     = ""
}

variable "custom_domain_names" {
  description = "The custom domain name for the API Gateway."
  type        = list(string)
  default     = []
}
