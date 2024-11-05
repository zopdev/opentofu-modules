# Zop-System

#### Variables

| Inputs           | Type   | Required/Optional | <div style="width:400px">Description</div>                                           | Default |
|------------------|--------|-------------------|----------------------------------------------------------------------------------------|---------|
| app_region       | string | Required          | App region of the cluster                                                               |         |
| bucket_name      | string | Required          | Name of the bucket remote state bucket                                                   |         |
| cluster_name     | string | Required          | Name of the cluster on which zop-system should be deployed                              |         |
| cluster_prefix   | string | Required          | Prefix for cluster terraform state file                                                 | `""`    |
| host             | string | Required          | Domain to be used for zop-system                                                         |         |
| provider_id      | string | Required          | ID of the GCP project                                                                    |         |
