resource "aws_db_parameter_group" "main" {
  count = var.use_aurora ? 0 : 1

  name        = "${var.name_prefix}-${local.selected_engine}-parameter-group"
  family      = local.parameter_group_family
  description = "Parameter group for ${var.name_prefix} RDS ${local.selected_engine}"

  dynamic "parameter" {
    for_each = local.db_parameters

    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-${local.selected_engine}-parameter-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "main" {
  count = var.use_aurora ? 0 : 1

  identifier = "${var.name_prefix}-rds"

  engine         = local.selected_engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted

  db_name  = var.db_name
  username = var.master_username
  password = var.master_password

  port                   = local.db_port
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main.id]
  parameter_group_name   = aws_db_parameter_group.main[0].name

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : (
    var.final_snapshot_identifier != null ? var.final_snapshot_identifier : "${var.name_prefix}-rds-final-snapshot"
  )

  apply_immediately = var.apply_immediately

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-rds"
      Type = "rds-instance"
    }
  )
}
