# `/prod-stackit/terraform`

## Directory Structure

### `./10_launchpad`

This directory contains all the necessary files and configurations to run Terraform within GitHub Actions.

### `./50_projects`

Each subdirectory within `./50_projects` corresponds to a specific StackIT project. These subdirectories contain the complete deployment configurations for their respective projects.

## Terraform Provider Authentication

### Personal User

You can authenticate against the StackIT API with your personal user using the StackIT Terraform Provider [Token Flow](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs#token-flow) authentication method.

Currently, it is not possible to create a Personal Access Token in the StackIT Portal. However, who needs a UI anyway, right? This documentation will focus on the [`stackit`](https://github.com/stackitcloud/stackit-cli/blob/main/INSTALLATION.md) CLI only.

Follow these steps to generate a Personal Access Token and use it with StackIT's Terraform Provider:

1. Run `stackit auth login`.

2. After successfully logging in, generate a short-lived personal access token and store it in the environment variable `STACKIT_SERVICE_ACCOUNT_TOKEN`. This token will be recognized by the StackIT Terraform provider.

    ```shell
    export STACKIT_SERVICE_ACCOUNT_TOKEN=$(stackit auth get-access-token 2>/dev/stdout)
    ```

3. That's it! Now you can use `terraform` with the StackIT provider.

> [!CAUTION]
> This authentication is only needed for authentication against the StackIT API to create resources with the StackIT Terraform provider. If the Terraform State file is located remotely on a StackIT Object Store, backend authentication needs to be done separately, because the StackIT Object Store credentials and permissions system are separate from the StackIT API permission system. You need access to the StackIT Object Store by providing an access key and a secret key.

## Well Known Server Images

| Name                         | ID                                     |
| ---------------------------- | -------------------------------------- |
| Debian 12                    | `a1413b23-b529-45a3-8323-44b7b91b1828` |
| Debian 12 ARM64              | `d98c436c-ff52-4e81-9353-cdd73598d415` |
| Ubuntu 24.04                 | `117e8764-41c2-405f-aece-b53aa08b28cc` |
| Ubuntu 24.04 ARM64           | `882a8fdc-3bc9-403e-96e0-e1c92a8ed7a9` |
| Windows Server 2025 Standard | `02bd744c-16d6-4765-bb95-520e141c9296` |

For all available images see [images.json](images.json), or use:

```shell
PROJECT_ID=00000000-0000-0000-0000-000000000000 # Set you project ID
stackit curl https://iaas.api.eu01.stackit.cloud/v1beta1/projects/$PROJECT_ID/images
```

## Server Types

See <https://docs.stackit.cloud/stackit/en/virtual-machine-flavors-75137231.html> and <https://www.stackit.de/en/pricing/cloud-services/iaas/stackit-compute-engine/>

## Availability Zones

See <https://docs.stackit.cloud/stackit/en/regions-and-availability-zones-75137212.html>

- `eu01-1`
- `eu01-2`
- `eu03-3`
- `eu01-m` (Metro Zone is not available for ARM machine types)

## Storage Performance classes

See <https://docs.stackit.cloud/stackit/en/service-plans-blockstorage-75137974.html#ServiceplansBlockStorage-CurrentlyavailableServicePlans%28performanceclasses%29>

| Performance class    | Name (Terraform)       | Max. IOPS | Max. Througput (MB/s) |
| -------------------- | ---------------------- | --------- | --------------------- |
| Performance class 0  | storage_premium_perf0  | 120       | 25                    |
| Performance class 1  | storage_premium_perf1  | 500       | 50                    |
| Performance class 2  | storage_premium_perf2  | 1000      | 100                   |
| Performance class 4  | storage_premium_perf4  | 2000      | 150                   |
| Performance class 6  | storage_premium_perf6  | 5000      | 200                   |
| Performance class 8  | storage_premium_perf8  | 10000     | 250                   |
| Performance class 10 | storage_premium_perf10 | 15000     | 300                   |
| Performance class 12 | storage_premium_perf12 | 20000     | 350                   |
