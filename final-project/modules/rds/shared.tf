locals {
  selected_engine = var.use_aurora ? (
    var.engine == "postgres" ? "aurora-postgresql" :
    var.engine == "mysql" ? "aurora-mysql" :
    var.engine
  ) : var.engine

  version_parts = split(".", var.engine_version)

  postgres_major = local.version_parts[0]

  mysql_major = length(local.version_parts) >= 2 ? "${local.version_parts[0]}.${local.version_parts[1]}" : local.version_parts[0]

  is_postgres = contains(["postgres", "aurora-postgresql"], local.selected_engine)
  is_mysql    = contains(["mysql", "aurora-mysql"], local.selected_engine)

  db_port = var.port != null ? var.port : (
    local.is_postgres ? 5432 : 3306
  )

  default_parameter_group_family = (
    local.selected_engine == "postgres" ? "postgres${local.postgres_major}" :
    local.selected_engine == "mysql" ? "mysql${local.mysql_major}" :
    local.selected_engine == "aurora-postgresql" ? "aurora-postgresql${local.postgres_major}" :
    local.selected_engine == "aurora-mysql" ? "aurora-mysql${local.mysql_major}" :
    null
  )

  parameter_group_family = var.parameter_group_family != null ? var.parameter_group_family : local.default_parameter_group_family

  default_postgres_parameters = {
    max_connections = {
      value        = "100"
      apply_method = "pending-reboot"
    }

    log_statement = {
      value        = "all"
      apply_method = "immediate"
    }

    work_mem = {
      value        = "4096"
      apply_method = "immediate"
    }
  }

  default_mysql_parameters = {
    max_connections = {
      value        = "100"
      apply_method = "pending-reboot"
    }
  }

  db_parameters = var.parameters != null ? var.parameters : (
    local.is_postgres ? local.default_postgres_parameters : local.default_mysql_parameters
  )

  common_tags = merge(
    var.tags,
    {
      Project = var.name_prefix
      Module  = "rds"
    }
  )
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-db-subnet-group"
    }
  )
}

resource "aws_security_group" "main" {
  name        = "${var.name_prefix}-db-sg"
  description = "Security group for ${var.name_prefix} database"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-db-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = toset(var.allowed_cidr_blocks)

  security_group_id = aws_security_group.main.id
  description       = "Allow database access from CIDR ${each.value}"

  cidr_ipv4   = each.value
  ip_protocol = "tcp"
  from_port   = local.db_port
  to_port     = local.db_port
}

resource "aws_vpc_security_group_ingress_rule" "security_group" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id = aws_security_group.main.id
  description       = "Allow database access from security group ${each.value}"

  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = local.db_port
  to_port                      = local.db_port
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.main.id
  description       = "Allow all outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
