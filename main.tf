# VPC for EKS
module "vpc_for_eks" {
  source = "./modules/vpc"
  project_name       = var.project_name
  vpc_tag_name       = "${var.project_name}-vpc"
  region             = var.region
  availability_zones = var.availability_zones
  vpc_cidr_block     = var.vpc_cidr_block
}

# RDS
module "rds" {
  source = "./modules/rds"
  region             = var.region
  availability_zone  = var.availability_zones[0]
  vpc_id             = module.vpc_for_eks.vpc_id
  database_subnetids = module.vpc_for_eks.private_subnet_ids
  database_username  = var.database_credentials.username
  database_password  = var.database_credentials.password
  database_port      = var.database_credentials.port
  database_name      = var.database_credentials.name

  depends_on         = [module.vpc_for_eks]
}


# Elasticache
module "elasticache" {
  source = "./modules/elasticache"
  replication_group_id = "${var.project_name}-redis-cluster"
  redis_port           = var.redis_port
  project_name         = var.project_name
  region               = var.region
  availability_zones   = var.availability_zones
  vpc_id               = module.vpc_for_eks.vpc_id
  vpc_cidr_block       = var.vpc_cidr_block
  database_subnetids   = module.vpc_for_eks.private_subnet_ids

  depends_on         = [module.vpc_for_eks]
}


# EKS Cluster
module "eks_cluster" {
  source = "./modules/eks"

  # Cluster
  vpc_id                 = module.vpc_for_eks.vpc_id
  cluster_sg_name        = "${var.project_name}-cluster-sg"
  nodes_sg_name          = "${var.project_name}-node-sg"
  eks_cluster_name       = var.project_name
  eks_cluster_subnet_ids = flatten([module.vpc_for_eks.public_subnet_ids, module.vpc_for_eks.private_subnet_ids])

  # Node group configuration (including autoscaling configurations)
  ami_type         = "AL2_x86_64"
  disk_size        = 20
  instance_types   = ["t2.small"]
  pvt_desired_size   = 1
  pvt_max_size       = 8
  pvt_min_size       = 1
  pblc_desired_size  = 1
  pblc_max_size      = 2
  pblc_min_size      = 1
  endpoint_private_access = true
  endpoint_public_access  = true
  node_group_name         = "${var.project_name}-node-group"
  private_subnet_ids      = module.vpc_for_eks.private_subnet_ids
  public_subnet_ids       = module.vpc_for_eks.public_subnet_ids
  
  depends_on  = [module.vpc_for_eks]
}


# Deploy K8 manisfests via kubectl
module "app" {
  source = "./modules/app"
  project_name            = var.project_name

  database_host      = module.rds.rds_endpoint
  database_username  = var.database_credentials.username
  database_password  = var.database_credentials.password
  database_port      = var.database_credentials.port
  database_name      = var.database_credentials.name

  redis_host         = module.elasticache.primary_endpoint_address
  redis_port         = var.redis_port

  depends_on        = [module.eks_cluster, module.rds, module.elasticache]
}


# Authorizer: Cognito + Lambda + API GW
module "authorizer" {
  source = "./modules/authorizer"
  project_name            = var.project_name
  region                  = var.region
  lb_service_name_orders  = module.app.lb_service_name_orders
  lb_service_port_orders  = module.app.lb_service_port_orders
  lb_service_name_production = module.app.lb_service_name_production
  lb_service_port_production = module.app.lb_service_port_production
  vpc_id                  = module.vpc_for_eks.vpc_id
  private_subnet_ids      = module.vpc_for_eks.private_subnet_ids
  environment             = "dev"
  cognito_user_name       = var.cognito_test_user.username
  cognito_user_password   = var.cognito_test_user.password

  depends_on         = [module.app]
}


