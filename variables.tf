variable "create" {
  type    = bool
  default = true
}

variable "work_group" {
  description = "The name of workgroup"
  type        = string
}

variable "enforce_workgroup_configuration" {
  description = "Whether the settings for the workgroup override client-side settings"
  type        = bool
  default     = false
}

variable "publish_cloudwatch_metrics_enabled" {
  description = "Whether Amazon CloudWatch metrics are enabled for the workgroup."
  type        = bool
  default     = true
}
variable "s3_bucket_requester_pays_enabled" {
  description = "Whether allows members assigned to a workgroup to reference Amazon S3 Requester Pays buckets in queries"
  type        = bool
  default     = false
}

variable "bytes_scanned_cutoff_per_query" {
  description = "Integer for the upper data usage limit (cutoff) for the amount of bytes a single query in a workgroup is allowed to scan. Must be at least 10485760."
  type        = number
  default     = null

  validation {
    condition     = var.bytes_scanned_cutoff_per_query == null || var.bytes_scanned_cutoff_per_query >= 10485760
    error_message = "bytes_scanned_cutoff_per_query must be at least 10485760 (10MB)."
  }
}

variable "s3_output_location" {
  description = "Location in Amazon S3 where your query results are stored, such as s3://path/to/query/bucket/"
  type        = string
  validation {
    condition     = can(regex("^s3://", var.s3_output_location))
    error_message = "The s3 output_location variable must have a 's3://' prefix."
  }
}

variable "s3_expected_bucket_owner" {
  description = "AWS account ID that you expect to be the owner of the Amazon S3 bucket."
  type        = string
  default     = null
}

variable "encryption_option" {
  type        = string
  default     = null
  description = <<EOF
Whether Amazon S3 server-side encryption with Amazon S3-managed keys (SSE_S3),
  server-side encryption with KMS-managed keys (SSE_KMS),
  or client-side encryption with KMS-managed keys (CSE_KMS) is used.
EOF

  validation {
    condition     = var.encryption_option == null || contains(["SSE_S3", "SSE_KMS", "CSE_KMS"], coalesce(var.encryption_option, ""))
    error_message = "encryption_option must be one of: SSE_S3, SSE_KMS, CSE_KMS."
  }
}

variable "kms_key_arn" {
  description = "For SSE_KMS and CSE_KMS, this is the KMS key ARN."
  type        = string
  default     = null
}

variable "enabled_s3_acl_option" {
  description = "Whether enabled s3 acl option, if true s3_acl_option' will set `BUCKET_OWNER_FULL_CONTROL`"
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}