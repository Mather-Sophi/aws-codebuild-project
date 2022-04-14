variable "name" {
  type        = string
  description = "(Required) The name of the codebuild project and artifact bucket"
}

variable "deploy_type" {
  type        = string
  description = "(Required) Must be one of the following ( ecr, ecs, lambda )"
}

variable "ecr_name" {
  type        = string
  description = "(Optional) The name of the ECR repo. Required if var.deploy_type is ecr or ecs"
  default     = null
}

variable "codebuild_image" {
  type        = string
  description = "(Optional) The codebuild image to use"
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:1.0"
}

variable "build_compute_type" {
  type        = string
  description = "(Optional) build environment compute type"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "buildspec" {
  type        = string
  description = "build spec file other than buildspec.yml"
  default     = "buildspec.yml"
}

variable "logs_retention_in_days" {
  type        = number
  description = "(Optional) Days to keep the cloudwatch logs for this codebuild project"
  default     = 14
}

variable "use_docker_credentials" {
  type        = bool
  description = "(Optional) Use dockerhub credentals stored in parameter store"
  default     = false
}
variable "env_repo_name" {
  type = object({
    variables = map(string)
  })
  default = null
}

variable "privileged_mode" {
  description = "set privileged_mode flag for docker container use"
  default     = false

}
variable "tags" {
  type        = map
  description = "(Optional) A mapping of tags to assign to the resource"
  default     = {}
}

variable "use_repo_access_github_token" {
  type        = bool
  description = <<EOT
                (Optional) Allow the AWS codebuild IAM role read access to the REPO_ACCESS_GITHUB_TOKEN secrets manager secret in the shared service account.
                Defaults to false.
                EOT
  default     = false
}

variable "svcs_account_github_token_aws_secret_arn" {
  type        = string
  description = <<EOT
                (Optional) The AWS secret ARN for the repo access Github token.
                The secret is created in the shared service account.
                Required if var.use_repo_access_github_token is true.
                EOT
  default     = null
}

variable "svcs_account_aws_kms_cmk_arn" {
  type        = string
  description = <<EOT
                (Optional) The us-east-1 region AWS KMS customer managed key ARN for encrypting all AWS secrets.
                The key is created in the shared service account.
                Required if var.use_repo_access_github_token or var.use_sysdig_api_token is true.
                EOT
  default     = null
}

variable "s3_block_public_access" {
  type = bool
  description = "(Optional) Enable the S3 block public access setting for the artifact bucket."
  default = false
}

variable "use_sysdig_api_token" {
  type        = bool
  description = <<EOT
                (Optional) Allow the AWS codebuild IAM role read access to the SYSDIG_API_TOKEN secrets manager secret in the shared service account.
                Defaults to false.
                EOT
  default     = false
}

variable "svcs_account_sysdig_api_token_aws_secret_arn" {
  type        = string
  description = <<EOT
                (Optional) The AWS secret ARN for the sysdig API token.
                The secret is created in the shared service account.
                Required if var.use_sysdig_api_token is true.
                EOT
  default     = null
}