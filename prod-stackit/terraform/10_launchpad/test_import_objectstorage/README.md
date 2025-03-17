# Test Import Objectstorage

Given is this Terraform root module to test a simple import of the STACKIT Object Storage.

When running terraform plan:

```bash
terraform plan
```

Then the output should be one import:

```plain
data.stackit_resourcemanager_project.this: Reading...
data.stackit_resourcemanager_project.this: Read complete after 1s [id=launchpad]
stackit_objectstorage_bucket.clicked: Preparing import... [id=6b590d5d-f2ab-4584-9556-5ed8bbabb796,launchpad]
stackit_objectstorage_bucket.clicked: Refreshing state...

Terraform will perform the following actions:

  # stackit_objectstorage_bucket.clicked will be imported
    resource "stackit_objectstorage_bucket" "clicked" {
        id                       = "6b590d5d-f2ab-4584-9556-5ed8bbabb796,launchpad"
        name                     = "launchpad"
        project_id               = "6b590d5d-f2ab-4584-9556-5ed8bbabb796"
        region                   = "eu01"
        url_path_style           = "https://object.storage.eu01.onstackit.cloud/launchpad"
        url_virtual_hosted_style = "https://launchpad.object.storage.eu01.onstackit.cloud"
    }

Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
```
