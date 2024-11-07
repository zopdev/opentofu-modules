# Remote-State

#### Variables

| Inputs             | Type   | Required/Optional | <div style="width:400px">Description</div>                                            | Default |
|--------------------|--------|-------------------|---------------------------------------------------------------------------------------|---------|
| bucket_prefix      | string | Required          | Prefix of the storage container blob.                                                 |         |
| container          | string | Required          | Name of the container which stores tfstate files.                                      |         |
| resource_group     | string | Required          | The Azure Resource Group name in which all resources should be created.               |         |
| storage_account    | string | Required          | Name of the storage account.                                                             |         |
