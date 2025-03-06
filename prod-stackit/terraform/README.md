# `/prod-stackit/terraform`

## Directory Structure

### `./10_launchpad`

This directory contains all the necessary files and configurations to run Terraform within GitHub Actions.

### `./50_projects`

Each subdirectory within `./50_projects` corresponds to a specific StackIT project. These subdirectories contain the complete deployment configurations for their respective projects.

## Well Known Server Images

| Name               | ID                                     |
| ------------------ | -------------------------------------- |
| Ubuntu 24.04       | `117e8764-41c2-405f-aece-b53aa08b28cc` |
| Ubuntu 24.04 ARM64 | `882a8fdc-3bc9-403e-96e0-e1c92a8ed7a9` |

For all Images available use `stackit curl https://iaas.api.eu01.stackit.cloud/v1beta1/projects/$PROJECT_ID/images` or see [images.json](images.json)

## Server Types

See <https://docs.stackit.cloud/stackit/en/virtual-machine-flavors-75137231.html> and <https://www.stackit.de/en/pricing/cloud-services/iaas/stackit-compute-engine/>

## Availability Zones

See <https://docs.stackit.cloud/stackit/en/regions-and-availability-zones-75137212.html>

- `eu01-1`
- `eu01-2`
- `eu03-3`
- `eu01-m` (Metro Zone is not available for ARM machine types)
