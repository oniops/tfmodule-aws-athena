output "workgroup_id" {
  value = try(aws_athena_workgroup.this.id, "")
}

output "workgroup_name" {
  value = try(aws_athena_workgroup.this.name, "")
}

output "workgroup_arn" {
  value = try(aws_athena_workgroup.this.arn, "")
}
