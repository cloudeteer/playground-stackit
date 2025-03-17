# Launchpad

This document details the initial setup process for the Launchpad on STACKIT Cloud.

## 1. Launchpad Service Account

### Authentication

We first logged in with a personal user account that had **Organization Owner** rights.

```console
$ stackit auth login
Successfully logged into STACKIT CLI.
```

We set the organization ID statically because, unfortunately, the CLI wasn't feeling cooperative.

```console
$ STACKIT_ORGANIZATION_ID=6f0a04e7-8d5f-42a5-b1b3-89b8532126db
```

To avoid missing crucial details in CLI output, we switched to json format:

```console
$ stackit config set --output-format json
```

### Creating the STACKIT Project

The launchpad project was created under our organization:

```console
$ stackit project create --name launchpad --parent-id "$STACKIT_ORGANIZATION_ID"
Are you sure you want to create a project under the parent with ID "6f0a04e7-8d5f-42a5-b1b3-89b8532126db"? [y/N] y
{
  "containerId": "launchpad-MyKfrt1",
  "creationTime": "2025-03-05T19:45:07.325899101Z",
  "labels": {},
  "lifecycleState": "CREATING",
  "name": "launchpad",
  "parent": {
    "containerId": "cloudeteer-gmb-h-iKVDWA1",
    "id": "6f0a04e7-8d5f-42a5-b1b3-89b8532126db",
    "type": "ORGANIZATION"
  },
  "projectId": "6b590d5d-f2ab-4584-9556-5ed8bbabb796",
  "updateTime": "2025-03-05T19:45:07.325899101Z"
}
```

For convenience, we set the project ID as a configuration parameter:

```console
$ stackit config set --project-id 6b590d5d-f2ab-4584-9556-5ed8bbabb796
```

### Creating and Configuring the Service Account

A Service Account with **Organization Owner** permissions was created:

```console
$ stackit service-account create --name launchpad
Are you sure you want to create a service account for project "launchpad"? [y/N] y
{
  "email": "launchpad-z3sy221@sa.stackit.cloud",
  "id": "3e57ce0e-d7f6-48b8-865a-1336e547dde4",
  "internal": false,
  "projectId": "6b590d5d-f2ab-4584-9556-5ed8bbabb796"
}
```

The generated email was saved for later:

```console
$ STACKIT_SERVICE_ACCOUNT_EMAIL=launchpad-z3sy221@sa.stackit.cloud
```

We then granted Organization Owner privileges to the Service Account:

```console
$ stackit organization member add "$STACKIT_SERVICE_ACCOUNT_EMAIL" \
    --organization-id "$STACKIT_ORGANIZATION_ID" \
    --role organization.owner
Are you sure you want to add the organization.owner role to launchpad-z3sy221@sa.stackit.cloud on organization with ID "6f0a04e7-8d5f-42a5-b1b3-89b8532126db"? [y/N] y
Member added
```

### Generating a Service Account Key

A key was generated and securely stored as a GitHub secret:

```console
$ stackit service-account key create --email "$STACKIT_SERVICE_ACCOUNT_EMAIL" |
    gh secret set CDT_LAUNCHPAD_STACKIT_SERVICE_ACCOUNT_KEY
Are you sure you want to create a key for service account launchpad-z3sy221@sa.stackit.cloud? The key will be valid until deleted [y/N] y
Created key for service account launchpad-z3sy221@sa.stackit.cloud with ID "a93c1c11-7710-49bf-b235-4d6b3aa1d708"
✓ Set Actions secret CDT_LAUNCHPAD_STACKIT_SERVICE_ACCOUNT_KEY for cloudeteer/playground-stackit
```

## 2. Terraform Remote State Backend

### Enabling Object Storage

To store Terraform remote state, we needed an S3-compatible Object Store. Initially, we attempted to create a storage bucket:

```console
$ stackit object-storage bucket create launchpad
Are you sure you want to create bucket "launchpad"? (This cannot be undone) [y/N] y
Error: This service isn't enabled for the current project.

To enable it, run:
  $ stackit object-storage enable
```

So, we enabled the Object Storage service:

```console
$ stackit object-storage enable
Are you sure you want to enable Object Storage for project "launchpad"? [y/N] y
Enabled Object Storage for project "launchpad"
```

Once enabled, we successfully created the bucket:

```console
$ stackit object-storage bucket create launchpad
Are you sure you want to create bucket "launchpad"? (This cannot be undone) [y/N] y
Creating bucket ✓
{
  "bucket": "launchpad",
  "project": "6b590d5d-f2ab-4584-9556-5ed8bbabb796"
}
```

### Creating Object Storage Credentials

Since Organization Owner rights were not enough for accessing Object Storage, we had to create an additional access key:

```console
$ stackit object-storage credentials-group create --name launchpad
Are you sure you want to create a credentials group with name "launchpad"? [y/N] y
{
  "credentialsGroup": {
    "credentialsGroupId": "76555949-9eee-442d-82ad-a3c3481b6f6a",
    "displayName": "launchpad",
    "urn": "urn:sgws:identity::79244107857127418979:group/credentials-group-49bb71"
  },
  "project": "6b590d5d-f2ab-4584-9556-5ed8bbabb796"
}
```

Then, we generated credentials and stored them securely as GitHub secrets:

```console
$ temp=$(stackit object-storage credentials create --credentials-group-id 76555949-9eee-442d-82ad-a3c3481b6f6a)

$ echo $temp | jq -r .accessKey | gh secret set CDT_LAUNCHPAD_STACKIT_BACKEND_ACCESS_KEY
✓ Set Actions secret CDT_LAUNCHPAD_STACKIT_BACKEND_ACCESS_KEY for cloudeteer/playground-stackit

$ echo $temp | jq -r .secretAccessKey | gh secret set CDT_LAUNCHPAD_STACKIT_BACKEND_SECRET_ACCESS_KEY
✓ Set Actions secret CDT_LAUNCHPAD_STACKIT_BACKEND_SECRET_ACCESS_KEY for cloudeteer/playground-stackit

$ unset temp
```

## Summary

- Service Account with Organization Owner permissions created.
- Object Storage provisioned for Terraform Remote State.
- Credentials securely stored as GitHub secrets.

Currently, a Launchpad Virtual Machine for a GitHub private runner is missing, but with STACKIT, we may explore this possibility in the coming weeks. 🚀
