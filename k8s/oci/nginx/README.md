# NGINX Module

Setting up the Ingress using the NGINX server.

## Variables

| Key                  | Type    | Required/Optional | Description                                                                 | Default     |
|----------------------|---------|-------------------|-----------------------------------------------------------------------------|-------------|
| oci_compartment_id   | string  | Required          | OCI Compartment ID where resources will be created                          |             |
| load_balancer_shape  | string  | Optional          | The shape of the load balancer                                              | "flexible"  |
| lb_subnet_id         | string  | Required          | The subnet OCID where the load balancer will be deployed                    |             |
| app_name             | string  | Required          | This is the name for the project and used to namespace resources            |             |
| lb_ip                | string  | Required          | Global IP address to be added in LoadBalancer                               |             |
| prometheus_enabled   | string  | Required          | Enable the creation of Prometheus based on user input                       |             |
