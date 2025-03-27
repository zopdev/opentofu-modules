# Artifacts

Setups the artifacts required in OCI.

## Variables

| Inputs       | Type         | Required/Optional | Description                                          | Default |
|-------------|-------------|-------------------|------------------------------------------------------|---------|
| services    | list(string) | Required          | List of services to be deployed within the namespace | `[]`    |
| provider_id | string       | Required          | Compartment ID where the resources will be created  | `""`    |
