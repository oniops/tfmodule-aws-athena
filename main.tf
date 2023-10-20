locals {
  create_athena      = var.create
  name_prefix        = var.context.name_prefix
  tags               = var.context.tags
  work_group         = "${local.name_prefix}-${var.work_group}"
  enabled_encryption = var.encryption_option != null && var.kms_key_arn != null ? true : false
}

resource "aws_athena_workgroup" "this" {
  count = local.create_athena ? 1 : 0
  name  = format("%s-athwg", local.work_group)

  configuration {
    enforce_workgroup_configuration    = var.enforce_workgroup_configuration
    publish_cloudwatch_metrics_enabled = var.publish_cloudwatch_metrics_enabled
    requester_pays_enabled             = var.s3_bucket_requester_pays_enabled
    bytes_scanned_cutoff_per_query     = var.bytes_scanned_cutoff_per_query

    engine_version {
      selected_engine_version = "AUTO"
    }

    result_configuration {
      output_location       = var.s3_output_location
      expected_bucket_owner = var.s3_expected_bucket_owner

      dynamic "encryption_configuration" {
        for_each = local.enabled_encryption ? ["true"] : []
        content {
          encryption_option = try(var.encryption_option, "SSE_S3")
          kms_key_arn       = try(var.kms_key_arn, null)
        }
      }

      dynamic "acl_configuration" {
        for_each = var.enabled_s3_acl_option ? ["true"] : []
        content {
          s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
        }
      }

    }

  }

  tags = merge(local.tags, {
    Name = format("%s-athwg", local.work_group)
  })

}
