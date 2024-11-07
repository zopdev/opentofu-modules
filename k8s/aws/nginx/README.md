# AWS kong Terraform module

This module is for deploying a private facing load balancer with nginx as ingress controller to the cluster.

## Variables

| Inputs                   | Type         | Required/Optional | <div style="width:450px">Description</div>                                                | Default          |
|--------------------------|--------------|-------------------|-------------------------------------------------------------------------------------------|------------------|
| app_env                  | string       | Required          | This is Environment where the NLB is deployed                                             |                  |
| app_name                 | string       | Required          | This is the name for the NLB                                                              |                  | 
| common_tags              | map(string)  | Required          | A map of common tags for the resources                                                    | `{}`             |
| inbound_ip               | list         | Optional          | List of ip range that are allowed access to services on EKS cluster                       | `["10.0.0.0/8"]` | 
| public_app               | bool         | Optional          | Whether application deploy on public ALB                                                  | `false`          |

