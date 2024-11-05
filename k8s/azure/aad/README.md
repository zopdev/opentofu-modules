# AZURE AAD Terraform module

Setting up the Azure Active Directory

## Variables

| Inputs                   | Type         | Required/Optional | <div style="width:450px">Description</div>                                                | Default          |
|--------------------------|--------------|-------------------|-------------------------------------------------------------------------------------------|------------------|
| users                  | list(string)       | Required          | List of User principal names to be added to AAD                                             | `[]`                 |
