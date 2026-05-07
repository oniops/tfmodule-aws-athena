# tfmodule-aws-athena

A Terraform module for provisioning an AWS Athena workgroup.

> Korean version: [README-ko.md](./README-ko.md)

## Features

- Creates an Athena workgroup (creation can be toggled per operational stack)
- Configures the S3 query result location and the expected bucket owner
- Supports server-side / client-side encryption (`SSE_S3`, `SSE_KMS`, `CSE_KMS`)
- Supports the S3 ACL option (`BUCKET_OWNER_FULL_CONTROL`)
- Per-query scanned-bytes cutoff
- CloudWatch metrics publication and the workgroup configuration enforcement option
- Workgroup name is auto-generated as `${context.name_prefix}-${var.work_group}-athwg`

## Usage

### Basic example

```hcl
module "ctx" {
  source = "git::https://github.com/oniops/tfmodule-context.git?ref=v1.3.5"
  context = {
    region      = "ap-northeast-2"
    project     = "demo"
    environment = "Development"
    owner       = "master@demoworks.com"
    team        = "DevOps"
    cost_center = "20211129"
    domain      = "demo.demoworks.com"
    pri_domain  = "demo.internal"
  }
}

module "athena" {
  source             = "git::https://github.com/oniops/tfmodule-aws-athena.git?ref=v1.0.0"
  context            = module.ctx.context
  work_group         = "demo"
  s3_output_location = "s3://your-s3-bucket/athena/output"
}
```

### Disable workgroup creation

Use this when you need to dynamically toggle workgroup creation per operational stack.

```hcl
module "athena" {
  source  = "git::https://github.com/oniops/tfmodule-aws-athena.git?ref=v1.0.0"
  create  = false
  context = module.ctx.context

  work_group         = "demo"
  # Even when create = false, the variable itself is required, so a valid s3:// path must be provided.
  s3_output_location = "s3://your-s3-bucket/athena/output"
}
```

### KMS encryption + S3 ACL

```hcl
module "athena" {
  source                   = "git::https://github.com/oniops/tfmodule-aws-athena.git?ref=v1.0.0"
  context                  = module.ctx.context
  work_group               = "demo"
  s3_output_location       = "s3://your-s3-bucket/athena/output"
  s3_expected_bucket_owner = "123456789012"
  encryption_option        = "SSE_KMS"
  kms_key_arn              = "arn:aws:kms:ap-northeast-2:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  enabled_s3_acl_option    = true

  enforce_workgroup_configuration    = true
  publish_cloudwatch_metrics_enabled = true
  bytes_scanned_cutoff_per_query     = 10485760
}
```

## Inputs

### context

| Name          | Description                  | Type          | Required |
|---------------|------------------------------|---------------|:--------:|
| `region`      | AWS region                   | `string`      | yes      |
| `project`     | Project name                 | `string`      | yes      |
| `name_prefix` | Resource name prefix         | `string`      | yes      |
| `pri_domain`  | Private (internal) domain    | `string`      | yes      |
| `tags`        | Common resource tags         | `map(string)` | yes      |

### Module Variables

| Name                                 | Description                                                                                                  | Type     | Default | Required |
|--------------------------------------|--------------------------------------------------------------------------------------------------------------|----------|---------|:--------:|
| `create`                             | Whether to create the workgroup. If `false`, the module creates no resources.                                | `bool`   | `true`  | no       |
| `work_group`                         | Workgroup name (the actual created name is `${name_prefix}-${work_group}-athwg`).                            | `string` | n/a     | yes      |
| `s3_output_location`                 | S3 location where query results are stored (must start with the `s3://` prefix).                             | `string` | n/a     | yes      |
| `s3_expected_bucket_owner`           | Expected owner AWS account ID of the result S3 bucket.                                                       | `string` | `null`  | no       |
| `enforce_workgroup_configuration`    | Whether the workgroup settings override client-side settings.                                                | `bool`   | `false` | no       |
| `publish_cloudwatch_metrics_enabled` | Whether to publish CloudWatch metrics.                                                                       | `bool`   | `true`  | no       |
| `s3_bucket_requester_pays_enabled`   | Whether to allow references to S3 Requester Pays buckets.                                                    | `bool`   | `false` | no       |
| `bytes_scanned_cutoff_per_query`     | Maximum bytes a single query is allowed to scan (minimum `10485760`).                                        | `number` | `null`  | no       |
| `encryption_option`                  | Encryption option (`SSE_S3` / `SSE_KMS` / `CSE_KMS`). Disabled when `null`.                                  | `string` | `null`  | no       |
| `kms_key_arn`                        | KMS key ARN used with `SSE_KMS` or `CSE_KMS`.                                                                | `string` | `null`  | no       |
| `enabled_s3_acl_option`              | Whether to enable the S3 ACL option. When `true`, `BUCKET_OWNER_FULL_CONTROL` is applied.                    | `bool`   | `false` | no       |

### When encryption is enabled

The `encryption_configuration` block is enabled when either of the following holds:

- `encryption_option = "SSE_S3"`, or
- `encryption_option` is not `null` and `kms_key_arn` is also provided (`SSE_KMS`, `CSE_KMS`).

## Outputs

| Name             | Description                  |
|------------------|------------------------------|
| `workgroup_id`   | ID of the created workgroup  |
| `workgroup_name` | Name of the created workgroup|
| `workgroup_arn`  | ARN of the created workgroup |

> When `create = false` and the workgroup is not created, all outputs above return an empty string (`""`).
