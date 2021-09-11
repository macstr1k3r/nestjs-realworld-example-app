resource "aws_ecs_cluster" "nrw" {
  name = "nrw-${terraform.workspace}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.tags.env
}
