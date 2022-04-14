## aws-codebuild-project

Creates a codebuild project and S3 artifact bucket to be used with codepipeline.

## Usage

```hcl
module "codebuild_project" {
  source = "github.com/globeandmail/aws-codebuild-project?ref=2.0"

  name        = var.name
  deploy_type = var.deploy_type
  ecr_name    = var.ecr_name
  tags        = var.tags
  svcs_account_github_token_aws_secret_arn = var.svcs_account_github_token_aws_secret_arn
  svcs_account_aws_kms_cmk_arn = var.svcs_account_aws_kms_cmk_arn
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| deploy\_type | \(Required\) Must be one of the following \( ecr, ecs, lambda \) | string | n/a | yes |
| name | \(Required\) The name of the codebuild project and artifact bucket | string | n/a | yes |
| build\_compute\_type | \(Optional\) build environment compute type | string | `"BUILD_GENERAL1_SMALL"` | no |
| use\_docker\_credentials | \(Optional\) Use dockerhub credentals stored in parameter store | bool | false | no |
| buildspec | build spec file other than buildspec.yml | string | `"buildspec.yml"` | no |
| codebuild\_image | \(Optional\) The codebuild image to use | string | `"aws/codebuild/amazonlinux2-x86_64-standard:1.0"` | no |
| ecr\_name | \(Optional\) The name of the ECR repo. Required if var.deploy\_type is ecr or ecs | string | `"null"` | no |
| logs\_retention\_in\_days | \(Optional\) Days to keep the cloudwatch logs for this codebuild project | number | `"14"` | no |
| tags | \(Optional\) A mapping of tags to assign to the resource | map | `{}` | no |
| use\_repo\_access\_github\_token | \(Optional\) Allow the AWS codebuild IAM role read access to the REPO\_ACCESS\_GITHUB\_TOKEN secrets manager secret in the shared service account.<br>Defaults to false. | `bool` | `false` | no |
| svcs\_account\_github\_token\_aws\_secret\_arn | \(Optional\) The AWS secret ARN for the repo access Github token.<br>The secret is created in the shared service account.<br>Required if var.use\_repo\_access\_github\_token is true. | `string` | `null` | no |
| svcs\_account\_aws\_kms\_cmk\_arn | \(Optional\)  The us-east-1 region AWS KMS customer managed key ARN for encrypting all AWS secrets.<br>The key is created in the shared service account.<br>Required if var.use\_repo\_access\_github\_token or var.use\_sysdig\_api\_token is true. | `string` | `null` | no |
| s3\_block\_public\_access | \(Optional\) Enable the S3 block public access setting for the artifact bucket. | `bool` | `false` | no |
| use\_sysdig\_api\_token | \(Optional\) Allow the AWS codebuild IAM role read access to the SYSDIG\_API\_TOKEN secrets manager secret in the shared service account.<br>Defaults to false. | `bool` | `false` | no |
| svcs\_account\_sysdig\_api\_token\_aws\_secret\_arn | \(Optional\) The AWS secret ARN for the sysdig API token.<br>The secret is created in the shared service account.<br>Required if var.use\_sysdig\_api\_token is true. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| artifact\_bucket\_arn |  |
| artifact\_bucket\_id |  |
| codebuild\_project\_arn |  |
| codebuild\_project\_id |  |