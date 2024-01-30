## aws-codebuild-project

Creates a codebuild project and S3 artifact bucket to be used with codepipeline.

## Usage

```hcl
module "codebuild_project" {
  source = "github.com/globeandmail/aws-codebuild-project?ref=2.2"

  name                                         = var.name
  deploy_type                                  = var.deploy_type
  ecr_name                                     = var.ecr_name
  build_compute_type                           = var.build_compute_type
  use_docker_credentials                       = var.use_docker_credentials
  buildspec                                    = var.buildspec
  tags                                         = var.tags
  use_repo_access_github_token                 = var.use_repo_access_github_token
  svcs_account_github_token_aws_secret_arn     = var.svcs_account_github_token_aws_secret_arn
  svcs_account_aws_kms_cmk_arn                 = var.svcs_account_aws_kms_cmk_arn
  s3_block_public_access                       = var.s3_block_public_access
  use_sysdig_api_token                         = var.use_sysdig_api_token
  svcs_account_sysdig_api_token_aws_secret_arn = var.svcs_account_sysdig_api_token_aws_secret_arn
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_compute_type"></a> [build\_compute\_type](#input\_build\_compute\_type) | (Optional) build environment compute type | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_buildspec"></a> [buildspec](#input\_buildspec) | build spec file other than buildspec.yml | `string` | `"buildspec.yml"` | no |
| <a name="input_codebuild_image"></a> [codebuild\_image](#input\_codebuild\_image) | (Optional) The codebuild image to use | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:1.0"` | no |
| <a name="input_deploy_type"></a> [deploy\_type](#input\_deploy\_type) | (Required) Must be one of the following ( ecr, ecs, lambda ) | `string` | n/a | yes |
| <a name="input_ecr_name"></a> [ecr\_name](#input\_ecr\_name) | (Optional) The name of the ECR repo. Required if var.deploy\_type is ecr or ecs | `string` | `null` | no |
| <a name="input_env_repo_name"></a> [env\_repo\_name](#input\_env\_repo\_name) | n/a | <pre>object({<br>    variables = map(string)<br>  })</pre> | `null` | no |
| <a name="input_logs_retention_in_days"></a> [logs\_retention\_in\_days](#input\_logs\_retention\_in\_days) | (Optional) Days to keep the cloudwatch logs for this codebuild project | `number` | `14` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the codebuild project and artifact bucket | `string` | n/a | yes |
| <a name="input_privileged_mode"></a> [privileged\_mode](#input\_privileged\_mode) | set privileged\_mode flag for docker container use | `bool` | `false` | no |
| <a name="input_s3_block_public_access"></a> [s3\_block\_public\_access](#input\_s3\_block\_public\_access) | (Optional) Enable the S3 block public access setting for the artifact bucket. | `bool` | `false` | no |
| <a name="input_svcs_account_aws_kms_cmk_arn"></a> [svcs\_account\_aws\_kms\_cmk\_arn](#input\_svcs\_account\_aws\_kms\_cmk\_arn) | (Optional) The us-east-1 region AWS KMS customer managed key ARN for encrypting all AWS secrets.<br>                The key is created in the shared service account.<br>                Required if var.use\_repo\_access\_github\_token or var.use\_sysdig\_api\_token is true. | `string` | `null` | no |
| <a name="input_svcs_account_github_token_aws_secret_arn"></a> [svcs\_account\_github\_token\_aws\_secret\_arn](#input\_svcs\_account\_github\_token\_aws\_secret\_arn) | (Optional) The AWS secret ARN for the repo access Github token.<br>                The secret is created in the shared service account.<br>                Required if var.use\_repo\_access\_github\_token is true. | `string` | `null` | no |
| <a name="input_svcs_account_sysdig_api_token_aws_secret_arn"></a> [svcs\_account\_sysdig\_api\_token\_aws\_secret\_arn](#input\_svcs\_account\_sysdig\_api\_token\_aws\_secret\_arn) | (Optional) The AWS secret ARN for the sysdig API token.<br>                The secret is created in the shared service account.<br>                Required if var.use\_sysdig\_api\_token is true. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource | `map(any)` | `{}` | no |
| <a name="input_use_docker_credentials"></a> [use\_docker\_credentials](#input\_use\_docker\_credentials) | (Optional) Use dockerhub credentals stored in parameter store | `bool` | `false` | no |
| <a name="input_use_repo_access_github_token"></a> [use\_repo\_access\_github\_token](#input\_use\_repo\_access\_github\_token) | (Optional) Allow the AWS codebuild IAM role read access to the REPO\_ACCESS\_GITHUB\_TOKEN secrets manager secret in the shared service account.<br>                Defaults to false. | `bool` | `false` | no |
| <a name="input_use_sysdig_api_token"></a> [use\_sysdig\_api\_token](#input\_use\_sysdig\_api\_token) | (Optional) Allow the AWS codebuild IAM role read access to the SYSDIG\_API\_TOKEN secrets manager secret in the shared service account.<br>                Defaults to false. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_artifact_bucket_arn"></a> [artifact\_bucket\_arn](#output\_artifact\_bucket\_arn) | n/a |
| <a name="output_artifact_bucket_id"></a> [artifact\_bucket\_id](#output\_artifact\_bucket\_id) | n/a |
| <a name="output_code_build_iam_role_name"></a> [code\_build\_iam\_role\_name](#output\_code\_build\_iam\_role\_name) | n/a |
| <a name="output_codebuild_project_arn"></a> [codebuild\_project\_arn](#output\_codebuild\_project\_arn) | n/a |
| <a name="output_codebuild_project_id"></a> [codebuild\_project\_id](#output\_codebuild\_project\_id) | n/a |
