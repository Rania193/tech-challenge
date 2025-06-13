resource "aws_ssm_parameter" "parameters" {
  for_each = var.parameters

  name  = "/${var.project_name}/${var.environment}/${each.key}"
  type  = "String"
  value = each.value
}