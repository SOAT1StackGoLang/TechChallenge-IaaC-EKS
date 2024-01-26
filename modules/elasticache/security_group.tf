resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id
}
resource "aws_security_group" "elasticache" {
  name        = "${var.project_name}-elasticache-sg"
  description = "Allow inbound to and outbound access from the Amazon ElastiCache cluster."
  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "Enable communication to the Amazon ElastiCache for Redis cluster. "
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Enable access to the ElastiCache cluster."
  }
  vpc_id = var.vpc_id
}