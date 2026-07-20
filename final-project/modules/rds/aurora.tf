resource "aws_rds_cluster_parameter_group" "main" {
  count = var.use_aurora ? 1 : 0

  name        = "${var.name_prefix}-${local.selected_engine}-cluster-parameter-group"
  family      = local.parameter_group_family
  description = "Cluster parameter group for ${var.name_prefix} Aurora ${local.selected_engine}"

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
      Name = "${var.name_prefix}-${local.selected_engine}-cluster-parameter-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster" "main" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${var.name_prefix}-aurora"

  engine         = local.selected_engine
  engine_version = var.engine_version

  database_name   = var.db_name
  master_username = var.master_username
  master_password = var.master_password

  port                   = local.db_port
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main.id]

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main[0].name

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : (
    var.final_snapshot_identifier != null ? var.final_snapshot_identifier : "${var.name_prefix}-aurora-final-snapshot"
  )

  storage_encrypted = var.storage_encrypted
  apply_immediately = var.apply_immediately

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-aurora"
      Type = "aurora-cluster"
    }
  )
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? var.aurora_instance_count : 0

  identifier         = "${var.name_prefix}-aurora-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.main[0].id

  engine         = aws_rds_cluster.main[0].engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_subnet_group_name = aws_db_subnet_group.main.name
  publicly_accessible  = var.publicly_accessible
  apply_immediately    = var.apply_immediately

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-aurora-${count.index + 1}"
      Type = count.index == 0 ? "aurora-writer" : "aurora-reader"
    }
  )
}
