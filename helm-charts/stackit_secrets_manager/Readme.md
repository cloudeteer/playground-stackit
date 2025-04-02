# create secret
vault login -method=userpass username= password=""

# create token (output of vault login)
printf 'sm.eb3a89180d36b8af89131617d84c1283e73b9588f897221257a552aef02ce47e' | base64

# put into templates/secrets-store.yaml
Secret: vault-token
data.token

# create secret in secret manager
vault kv put -mount=secret-manager-id secret/foo my-value=s3cr3t
