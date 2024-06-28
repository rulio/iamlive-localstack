# Iamlive with Localstack

This repo uses a modified version of `iamlive` that supports the `--aws-redirect-host` argument, which causes the `iamlive` proxy to forward requests to the specified host rather than AWS.

In this case, we make use of `--aws-redirect-host` to forward AWS requests to Localstack. This allows you to use the localstack services with the AWS SDK without any modification.

This repo provides a Terraform container for running terraform scripts on Localstack and getting IAM Policies from Iamlive.

It also provides an AWS cli container, but that container does not automatically add Iamlives certs to the containers trust certificate. That must be done to make it work fully.

## Usage

Clone the repository and navigate to the example directory:

```bash
git clone git@github.com:rulio/iamlive-localstack.git && cd iamlive-localstack
```

Copy `sample.env` to `.env` and modify as needed:

```bash
cp sample.env .env
```

Set the `TERRAFORM_TEMPLATES_DIR` and other environment variables in `.env` to the path of the Terraform templates directory.

Build the `iamlive` binary:

```bash
docker-compose build
```

Start the Localstack services:

```bash
docker-compose up
```

Connect to the `terraform` container:

```bash
docker-compose exec terraform sh
```

Now you can run Terraform commands in the `terraform` container:

Generate a plan

```bash
terraform plan
```

Apply the scripts

```bash
terraform apply
```

Write out the IAM policies

```bash
docker-compose exec iamlive kill -HUP 1
```

The IAM policies will be written to the `./iamlive/volumes/iam.policy` file.

## Terraform Provider Configuration

There are a few gotchas when using with terraform and they have to do with the provider configuration. Thie setup does not do authentication and it expects S3 requests to use Path style instead of Virtual Host syle requests.

That means you need to include the following settings in your provider configuration:

```hcl title="/terraform/main.tf"
provider "aws" {
  ...
 skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true
}
```

If you don't include these settings you may see `terraform apply` and `terraform plan` hang as they wait for validation or the account id.

Instead you can set the account id to with the `IAMLIVE_AWS_ACCOUNT_ID` environment variable in the `docker-compose.yaml` file.

## Troubleshooting

##### "CA key file exists without bundle file"

If you see this error when starting the `iamlive` container, it may mean that `ca.pem` and `ca.key` files were not created successfully. Do the following:

- Stop the containers with `docker-compose down`
- remove the `ca.pem` and `ca.key` files from the `./iamlive/volumes` directory
- Start the containers with `docker-compose up`

##### Terraform command hangs

This usually happens if the cert was not properly installed in the terraform container. `docker-compose down` followed by `docker-compose up` usually solves this issue. The terraform container is setup to import certs from iamlive then update its trust container. But if the certs are not yet created when the update cert command is run, it may need to be run again.
