data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub's OIDC thumbprint
}

# IAM user for microservices
resource "aws_iam_user" "app_user" {
  name = "${var.project_name}-user-${var.environment}"
  tags = {
    Name        = "${var.project_name}-user"
    Environment = var.environment
  }
}

resource "aws_iam_access_key" "app_user_key" {
  user = aws_iam_user.app_user.name
}

resource "aws_iam_user_policy" "app_user_policy" {
  name   = "${var.project_name}-user-policy-${var.environment}"
  user   = aws_iam_user.app_user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["ssm:DescribeParameters"]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*"
      },
      {
        Effect = "Allow"
        Action = ["ssm:GetParameters"]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/${var.environment}/*"
      }
    ]
  })
}

# IAM role for GitHub Actions with OIDC trust
resource "aws_iam_role" "github_actions_role" {
  name = "${var.project_name}-github-actions-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/main"
          }
        }
      },
      {
        Effect    = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/tags/release/*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-github-actions"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "github_actions_policy" {
  name   = "${var.project_name}-github-actions-policy-${var.environment}"
  role   = aws_iam_role.github_actions_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = var.repository_arn_list
        # Resource = "*"
      }
    ]
  })
}