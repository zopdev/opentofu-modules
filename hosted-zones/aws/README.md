# Hosted-Zones

#### Variables
| Inputs         | Type          | Required/Optional | <div style="width:400px">Description</div>                                                | Default |
|----------------|---------------|-------------------|------------------------------------------------------------------------------------------------|---------|
| master_zone    | string        | Required          | Master zone for NS record to be added                                                           | `""`    |
| provisioner    | string        | Required          | Provisioner being used to setup Infra                                                          | `zop-dev` |
| user_access    | object        | Required          | Map of roles for domain                                                                       | `{}`    |
| zones          | map(object)   | Required          | The list of user access for the account setup                                                  |         |

#### user_access
| Inputs                | Type          | Required/Optional | <div style="width:400px">Description</div> | Default |
|-----------------------|---------------|-------------------|--------------------------------------------|---------|
| user_access.editors   | list(string)  | Optional          | List of users or groups with editor access.                  |         |
| user_access.viewers   | list(string)  | Optional          | List of users or groups with viewer access.                  |         |

#### zones

| Inputs               | Type   | Required/Optional | <div style="width:400px">Description</div> | Default |
|----------------------|--------|-------------------|--------------------------------------------|---------|
| zones.add_ns_records | bool   | Required          | Whether to add NS records to the domain.                     |         |
| zones.domain         | string | Required          | The domain name for the zone configuration.                  |         |