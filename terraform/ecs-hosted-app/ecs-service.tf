locals {
  ecs_service_name = "${var.app.name}-ng-${terraform.workspace}"
}

resource "aws_ecs_service" "app-ng" {
  name             = local.ecs_service_name
  cluster          = var.cluster.id
  task_definition  = aws_ecs_task_definition.app-ng.id
  desired_count    = var.app.desired_count
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    assign_public_ip = true
    subnets          = var.app.subnet_ids
    security_groups = [
      aws_security_group.app-ng.id,
      aws_security_group.legacy-vpc.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app-ng.arn
    container_name   = "${var.product_name}-${var.app.name}-ng"
    container_port   = var.app.traffic_port
  }

  health_check_grace_period_seconds = 25


  # we don't want to mess up the autoscaling tbh
  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = local.base_tags
}
