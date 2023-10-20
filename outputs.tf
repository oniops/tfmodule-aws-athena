output "workgroup_id" {
  value = try(aws_athena_workgroup.this[0].id, "")
}

output "workgroup_name" {
  value = try(aws_athena_workgroup.this[0].name, "")
}

output "workgroup_arn" {
  value = try(aws_athena_workgroup.this[0].arn, "")
}
