NGINX module

Setting up the Ingress using nginx server.

## Variables

| Key                  | Type   | Required/Optional | Description                                                | Default |
|----------------------|--------|-------------------|------------------------------------------------------------|---------|
| app_name             | string  | Optional          | Name of AKS cluster                                       | `""`    |
| lb_ip                | string  | Required          | Static IP address to attach to loadbalancer.               |         |
| node_port            | number  | Required          | Node Port on which to expose Kong.                        |         |
| node_resource_group  | string  | Required          | Node Resource Group name.                                 |         |
| prometheus_enabled   | string  | Required          | Enable the creation of Prometheus based on user input.     |         |


