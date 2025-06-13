output "parameter_names" {
  description = "List of created parameter names"
  value       = [for k, v in aws_ssm_parameter.parameters : k]
}