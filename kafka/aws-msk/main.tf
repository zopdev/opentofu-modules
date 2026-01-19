data "aws_subnet" "app_subnet" {
  id = var.kafka_subnets.0
}

locals {
  vpc_id             = data.aws_subnet.app_subnet.vpc_id
  cluster_name_parts = split("-", var.kafka_cluster_name)
  environment        = element(local.cluster_name_parts, length(local.cluster_name_parts) - 1)
  common_tags = merge(var.common_tags,
    tomap({
      Project     = var.kafka_cluster_name,
      Provisioner = "TERRAFORM",
      Environment = local.environment,
  }))
}

resource "aws_security_group" "msk_sg" {
  name   = "${var.kafka_cluster_name}-msk-sg"
  vpc_id = local.vpc_id

  ingress {
    description = "To communicate with MSK that is set up using SASL/SCRAM Authentication"
    from_port   = 9096
    protocol    = "tcp"
    to_port     = 9096
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    description = "Apache ZooKeeper nodes use port 2181"
    from_port   = 2181
    protocol    = "tcp"
    to_port     = 2181
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "aws_log" {
  name = "${var.kafka_cluster_name}_msk_broker_logs"
  tags = local.common_tags
}

resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = var.kafka_cluster_name
  kafka_version          = "2.6.2"
  number_of_broker_nodes = var.kafka_broker_nodes == 0 ? length(var.kafka_subnets) : var.kafka_broker_nodes
  client_authentication {
    sasl {
      scram = true
    }
  }

  broker_node_group_info {
    instance_type   = var.kafka_broker_instance
    ebs_volume_size = var.kafka_size
    client_subnets  = var.kafka_subnets

    security_groups = [aws_security_group.msk_sg.id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.msk_kms_key.arn
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.aws_log.name
      }
    }
  }

  tags = local.common_tags
}

resource "aws_msk_scram_secret_association" "msk_secret_association" {
  cluster_arn     = aws_msk_cluster.msk_cluster.arn
  secret_arn_list = [aws_secretsmanager_secret.msk_secret.arn]

  depends_on = [aws_secretsmanager_secret_version.msk_secret]
}

# Required for root terragrunt module to inject backend s3 configs
# - https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/#motivation
terraform {
  backend "s3" {}
}
