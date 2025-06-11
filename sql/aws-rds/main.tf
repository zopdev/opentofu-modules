data "aws_availability_zones" "available" {}

locals {
  enable_ssl = var.enable_ssl == true ? 1 : 0

  db_type = {
    "postgresql" = {
      type                            = "postgres"
      enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
      version                         = var.postgresql_engine_version
      port                            = 5432
      parameter_group                 = {
        key    = "postgres16"
        values = [
          {
            name  = "log_connections"
            value = "1"
          },
          {
            name  = "log_min_duration_statement"
            value = var.log_min_duration_statement
          },
          {
            name  = "log_min_error_statement"
            value = "ERROR"
          },
          {
            name  = "rds.force_ssl"
            value = "${local.enable_ssl}"
          }
        ]
      }
    }
    "mysql"      = {
      type                            = "mysql"
      enabled_cloudwatch_logs_exports = ["error", "slowquery"]
      version                         = var.mysql_engine_version
      port                            = 3306
      parameter_group                 = {
        key    = "mysql8.0"
        values = [
          {
            name  = "character_set_server"
            value = "utf8"
          },
          {
            name  = "character_set_client"
            value = "utf8"
          },
          {
            name  = "slow_query_log"
            value = "1"
          },
          {
            name  = "log_output"
            value = "FILE"
          }
        ]
      }
    }
  }
}


resource "aws_db_subnet_group" "db_subnet" {
  name       = "${var.rds_name}-sg"
  subnet_ids =  var.db_subnets

  tags = merge(var.tags,
  tomap({
    "Name" = var.rds_name
  })
  )
}

resource "aws_security_group" "rds" {
  name   = "${var.rds_name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = local.db_type[var.rds_type].port
    to_port     = local.db_type[var.rds_type].port
    protocol    = "tcp"
    cidr_blocks = var.ext_rds_sg_cidr_block
  }

  egress {
    from_port   = local.db_type[var.rds_type].port
    to_port     = local.db_type[var.rds_type].port
    protocol    = "tcp"
    cidr_blocks = var.ext_rds_sg_cidr_block
  }

  tags = merge(var.tags,
  tomap({
    "Name" = var.rds_name
  })
  )
}

resource "aws_db_parameter_group" "db_param_group" {
  name   = "${var.rds_name}-pg"
  family = local.db_type[var.rds_type].parameter_group.key

  dynamic "parameter" {
    for_each = local.db_type[var.rds_type].parameter_group.values
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags,
  tomap({
    "Name" = var.rds_name
  })
  )
}

resource "aws_db_instance" "db_instance" {
  identifier                      = var.rds_name
  publicly_accessible             = false
  storage_encrypted               = true
  instance_class                  = var.instance_class
  allocated_storage               = var.allocated_storage
  engine                          = local.db_type[var.rds_type].type
  engine_version                  = local.db_type[var.rds_type].version
  username                        = var.admin_user
  password                        = aws_secretsmanager_secret_version.db_secret.secret_string
  db_subnet_group_name            = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  parameter_group_name            = aws_db_parameter_group.db_param_group.name
  skip_final_snapshot             = true
  multi_az                        = var.multi_az
  backup_retention_period         = 7
  performance_insights_enabled    = false
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = local.db_type[var.rds_type].enabled_cloudwatch_logs_exports
  max_allocated_storage           = var.max_allocated_storage
  apply_immediately               = var.apply_immediately
  storage_type                    = var.storage_tier
  iops                            = var.iops
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  tags = merge(var.tags,
  tomap({
    "Name" = var.rds_name
  })
  )
}

resource "aws_db_instance" "rds_read_replica" {
  count                           =  var.read_replica ? 1 : 0

  identifier                      = "rds-read-replica-${var.rds_name}"
  publicly_accessible             = false
  storage_encrypted               = true
  instance_class                  = var.instance_class 
  replicate_source_db             = aws_db_instance.db_instance.id
  allocated_storage               = var.allocated_storage
  vpc_security_group_ids          = [aws_security_group.rds.id]
  parameter_group_name            = aws_db_parameter_group.db_param_group.name
  skip_final_snapshot             = true
  multi_az                        = var.read_replica_multi_az
  performance_insights_enabled    = false
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = local.db_type[var.rds_type].enabled_cloudwatch_logs_exports
  max_allocated_storage           = var.max_allocated_storage
  apply_immediately               = var.apply_immediately
  storage_type                    = var.storage_tier
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  tags = merge(var.tags,
  tomap({
    "Name" = "rds-read-replica-${var.rds_name}"
  })
  )
}