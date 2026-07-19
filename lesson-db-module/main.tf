terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.bucket_name
  table_name  = var.table_name
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  vpc_name           = var.vpc_name
  eks_cluster_name   = var.eks_cluster_name
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  scan_on_push = var.scan_on_push
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  cluster_subnet_ids = concat(
    module.vpc.public_subnets,
    module.vpc.private_subnets
  )

  node_subnet_ids     = module.vpc.private_subnets
  node_instance_types = var.eks_node_instance_types

  desired_size = var.eks_desired_size
  min_size     = var.eks_min_size
  max_size     = var.eks_max_size
}

module "jenkins" {
  source = "./modules/jenkins"

  admin_password = var.jenkins_admin_password

  depends_on = [
    module.eks
  ]
}

module "argo_cd" {
  source = "./modules/argo_cd"

  depends_on = [
    module.eks
  ]
}
module "rds" {
  source = "./modules/rds"

  name_prefix = var.rds_name_prefix

  use_aurora = var.rds_use_aurora

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  allowed_cidr_blocks        = var.rds_allowed_cidr_blocks
  allowed_security_group_ids = var.rds_allowed_security_group_ids

  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  parameter_group_family = var.rds_parameter_group_family

  instance_class        = var.rds_instance_class
  aurora_instance_count = var.rds_aurora_instance_count

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = var.rds_storage_type
  storage_encrypted     = var.rds_storage_encrypted

  db_name         = var.rds_db_name
  master_username = var.rds_master_username
  master_password = var.rds_master_password

  port                = var.rds_port
  multi_az            = var.rds_multi_az
  publicly_accessible = var.rds_publicly_accessible

  backup_retention_period   = var.rds_backup_retention_period
  deletion_protection       = var.rds_deletion_protection
  skip_final_snapshot       = var.rds_skip_final_snapshot
  final_snapshot_identifier = var.rds_final_snapshot_identifier

  apply_immediately = var.rds_apply_immediately

  tags = {
    Environment = var.environment
    Lesson      = "lesson-db-module"
  }
}
