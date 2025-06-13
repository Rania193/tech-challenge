resource "aws_iam_user" "service_user" {
  name = "${var.project_name}-service-user-${var.environment}"
}

resource "aws_iam_user_policy" "service_policy" {
  name   = "${var.project_name}-service-policy"
  user   = aws_iam_user.service_user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ssm:GetParameters",
          "ssm:DescribeParameters"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "service_key" {
  user = aws_iam_user.service_user.name
}