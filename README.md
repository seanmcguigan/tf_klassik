# klassik-terraform

To deploy the klassik platform in AWS make sure you have the _klassik_deploy user AWS api key, otherwise you will encounter a 403 error.

Modify your aws credentials file and add the klassik profile:

```
[default]
aws_access_key_id = <your_key>
aws_secret_access_key = <your_access_key>

[klassik]
aws_access_key_id = <klassik_deploy_user_key>
aws_secret_access_key = <klassik_deploy_user_access_key>
```

To deploy a change pull the repo and cd to ENV qa/prod. Dependant on environment run one of the below terraform remote config commands, This will pull the terraform.tfstate file from the s3 bucket. Then run 'terraform plan' this should return
```
No changes. Infrastructure is up-to-date. This means that Terraform
could not detect any differences between your configuration and
the real physical resources that exist. As a result, Terraform
doesn't need to do anything.
```
Once you make your changes to the terraform code, run 'terraform apply'(this will update the s3terraform.tfstate file) then push the changes to github.

The result of 'terraform plan' should always be:
```
No changes. Infrastructure is up-to-date. This means that Terraform
could not detect any differences between your configuration and
the real physical resources that exist. As a result, Terraform
doesn't need to do anything.
```

For QA
```
terraform remote config -backend=S3 -backend-config="bucket=7digital-klassik-tfstate" -backend-config="key=qa/terraform.tfstate" -backend-config="region=eu-west-1"
```
For Prod
```
terraform remote config -backend=S3 -backend-config="bucket=7digital-klassik-tfstate" -backend-config="key=prod/terraform.tfstate" -backend-config="region=eu-west-1"
```
