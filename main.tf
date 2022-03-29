data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  aws_region      = data.aws_region.current.name
  account_id      = data.aws_caller_identity.current.account_id
  privileged_mode = var.deploy_type == "ecr" || var.deploy_type == "ecs" || var.privileged_mode == "true" ? true : false
}

resource "aws_s3_bucket" "artifact" {
  # S3 bucket cannot be longer than 63 characters
  bucket = lower(substr("codepipeline-${local.aws_region}-${local.account_id}-${var.name}", 0, 63))

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "artifact" {
  count  = var.s3_block_public_access ? 1 : 0
  bucket = aws_s3_bucket.artifact.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "artifact" {
  bucket = aws_s3_bucket.artifact.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "artifact" {
  bucket = aws_s3_bucket.artifact.id
  rule {
    id     = "expire"
    status = "Enabled"
    expiration {
      days = 90
    }
  }
}

resource "aws_cloudwatch_log_group" "group" {
  name              = "/aws/codebuild/${var.name}"
  retention_in_days = var.logs_retention_in_days

  tags = var.tags
}

data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "codebuild-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json

  tags = var.tags
}

data "aws_iam_policy_document" "codebuild_baseline" {
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
    ]
    resources = [
      "arn:aws:logs:${local.aws_region}:${local.account_id}:log-group:/aws/codebuild/${var.name}",
      "arn:aws:logs:${local.aws_region}:${local.account_id}:log-group:/aws/codebuild/${var.name}:*"
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.artifact.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_baseline" {
  name   = "codebuild-baseline-${var.name}"
  role   = aws_iam_role.codebuild.id
  policy = data.aws_iam_policy_document.codebuild_baseline.json
}

data "aws_iam_policy_document" "codebuild_ecr" {
  count = var.deploy_type == "ecr" || var.deploy_type == "ecs" ? 1 : 0

  statement {

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage"
    ]

    resources = ["arn:aws:ecr:${local.aws_region}:${local.account_id}:repository/${var.ecr_name}"]
  }

  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]

    resources = ["arn:aws:ecr:${local.aws_region}:${local.account_id}:repository/*"]
  }

  statement {
    actions   = ["ssm:GetParameters"]
    resources = ["arn:aws:ssm:${local.aws_region}:${local.account_id}:parameter/dockerhub/*"]
  }

}

resource "aws_iam_role_policy" "codebuild_ecr" {
  # Only create this if var.deploy_type is ecr or ecs
  count = var.deploy_type == "ecr" || var.deploy_type == "ecs" ? 1 : 0

  name   = "codebuild-ecr-${var.name}"
  role   = aws_iam_role.codebuild.id
  policy = data.aws_iam_policy_document.codebuild_ecr[count.index].json
}

data "aws_iam_policy_document" "codebuild_secrets_manager" {
  count = var.use_repo_access_github_token ? 1 : 0
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      replace(var.svcs_account_github_token_aws_secret_arn, "/-.{6}$/", "-??????")
    ]
  }

  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      var.svcs_account_github_token_aws_kms_cmk_arn
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_secrets_manager" {
  count  = var.use_repo_access_github_token ? 1 : 0
  name   = "codebuild-secrets-manager-${var.name}"
  role   = aws_iam_role.codebuild.id
  policy = data.aws_iam_policy_document.codebuild_secrets_manager[0].json
}

resource "aws_codebuild_project" "project" {
  name          = var.name
  build_timeout = 60
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.build_compute_type
    image           = var.codebuild_image
    type            = "LINUX_CONTAINER"
    privileged_mode = local.privileged_mode

    dynamic "environment_variable" {
      for_each = var.ecr_name == null ? [] : [var.env_repo_name]
      content {
        name  = "IMAGE_REPO_NAME"
        value = var.ecr_name
      }
    }

    environment_variable {
      name    = "AWS_ACCOUNT_ID"
      value   = local.account_id
    }

    dynamic "environment_variable" {
      for_each = var.ecr_image_tag == null ? [] : [var.env_repo_name]
      content {
        name    = "AWS_ACCOUNT_ID"
        value   = local.account_id
      }
    }

    dynamic "environment_variable" {
      for_each = var.ecr_image_tag == null ? [] : [var.env_repo_name]
      content {
        name  = "IMAGE_TAG"
        value = var.ecr_image_tag
      }
    }

    dynamic "environment_variable" {
      for_each = var.use_docker_credentials == true ? [1] : []
      content {
        name  = "DOCKERHUB_USER"
        value = "/dockerhub/user"
        type  = "PARAMETER_STORE"
      }
    }

    dynamic "environment_variable" {
      for_each = var.use_docker_credentials == true ? [1] : []
      content {
        name  = "DOCKERHUB_PASS"
        value = "/dockerhub/pass"
        type  = "PARAMETER_STORE"
      }
    }

    dynamic "environment_variable" {
      for_each = var.use_repo_access_github_token ? [1] : []
      content {
        name  = "REPO_ACCESS_GITHUB_TOKEN_SECRETS_ID"
        value = var.svcs_account_github_token_aws_secret_arn
        type  = "SECRETS_MANAGER"
      }
    }
  }


  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  tags = var.tags
}
