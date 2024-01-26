resource "aws_elasticache_subnet_group" "elasticache_subnet" {
  name       = "${var.project_name}-cache-subnet"
  subnet_ids = var.database_subnetids
}


#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group
resource "aws_elasticache_replication_group" "redis" {
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = var.availability_zones
  subnet_group_name           = aws_elasticache_subnet_group.elasticache_subnet.name
  replication_group_id        = var.replication_group_id
  description                 = "ElastiCache cluster"
  node_type                   = "cache.t2.small"
  parameter_group_name        = "default.redis7"
  #parameter_group_name       = "default.redis7.cluster.on"
  #num_cache_clusters          = 1
  port                        = var.redis_port
  multi_az_enabled            = false
  num_node_groups             = 1
  replicas_per_node_group     = 1
  at_rest_encryption_enabled  = false
  transit_encryption_enabled  = false
  security_group_ids          = [aws_security_group.elasticache.id]

  apply_immediately = true
}