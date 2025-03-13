# team-iac-test01

## Getting Started

To get started, follow these steps:

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`.
2. Customize the `terraform.tfvars` file to enable or disable the features you want to deploy.
3. Run `terraform apply`.

> [!NOTE]
> Your personal `terraform.tfvars` file will not be tracked by Git.

## SSH Access

This deployment generates an SSH private key and saves it to a local file named `./id_ed25519`. To connect to a server deployed by this setup, use the following command:

```shell
# Replace <USERNAME> and <HOST> with the appropriate values
ssh -i ./id_ed25519 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no <USERNAME>@<HOST>
```

## Adding a Feature

To add a new feature (StackIT Resource Test), follow these steps:

1. Create a directory in `./modules` for the new feature.
2. Add the new feature to `main.tf`.
3. Update the `features` variable in `variables.tf` and `terraform.tfvars.example`.

Refer to the existing features for examples. This approach allows independent testing of StackIT features without conflicts.
