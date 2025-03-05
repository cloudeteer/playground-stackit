# Terraform: team-iac-test01

## Getting started

### Create Object Store

```shell
brew tap stackitcloud/tap
brew install stackit
```

```shell
stackit auth login
stackit config set --project-id 341539db-8c67-43cf-ba1f-fd14157a0a5b # team-iac-test01
stackit object-storage enable
```

```shell
stackit object-storage bucket create team-iac-test01-tfstate
```

```shell
# Get object ID
credential_group_id=$(stackit object-storage credentials-group list --output-format json |
jq -r '.[] | select(.displayName == "default") | .credentialsGroupId)

# Create access key
stackit object-storage credentials create --credentials-group-id "$credential_group_id"
```
