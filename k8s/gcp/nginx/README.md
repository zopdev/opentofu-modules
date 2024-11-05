# GCP kong Terraform module

This module is for deploying a private facing load balancer with nginx as ingress controller to the cluster.

## Variables

| Inputs             | Type   | Required/Optional | <div style="width:420px">Description</div>                                                | Default |
|--------------------|--------|-------------------|-------------------------------------------------------------------------------------------|---------|
| app_env            | string | Required          | Name of the environment which can be used for uniquely identifying the NLB                |         |
| app_name           | string | Required          | Name of the cluster which can be used for uniquely identifying the NLB                    |         | 
| app_region         | string | Optional          | The GCP region used to create the resources                                               | `""`    |
| lb_ip              | string | Required          | Global IP address to be added in LoadBalancer                                             |         |
| node_port          | number | Required          | Node port on which to expose kong ingress controller so that target group can point to it |         |
| project            | string | Required          | Project ID where the resources to be created                                    |         |
| prometheus_enabled | string | Required          | Enable the creation of prometheus based on user input                                       | `true`  |
