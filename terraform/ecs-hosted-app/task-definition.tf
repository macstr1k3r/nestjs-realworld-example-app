locals {
  container_image = var.ecr_repo_settings.existing_repository_to_use == "" ? "605398246542.dkr.ecr.eu-central-1.amazonaws.com/${var.product_name}-${var.app.name}-ng-${terraform.workspace}:latest" : var.ecr_repo_settings.existing_repository_to_use
}

resource "aws_ecs_task_definition" "app-ng" {
  family       = "${var.product_name}-${var.app.name}-ng-${terraform.workspace}"
  network_mode = "awsvpc"


  execution_role_arn = aws_iam_role.app-ng.arn # assumed by the ecs/docker daemon
  # task_role_arn      = aws_iam_role.app-ng.arn # assumed by my service at runtime


  container_definitions = jsonencode([{
    name : "${var.product_name}-${var.app.name}-ng",
    image : local.container_image
    essential : true,
    portMappings : [{
      protocol : "tcp",
      hostPort : var.app.traffic_port,
      containerPort : var.app.traffic_port,
    }],
    logConfiguration : {
      logDriver : "awslogs",
      options : {
        "awslogs-group" : aws_cloudwatch_log_group.app-ng.id,
        "awslogs-region" : data.aws_region.app-ng.name,
        "awslogs-stream-prefix" : var.app.name,
      }
    },

    cpu : 0,
    mountPoints = [],
    volumesFrom = [],

    environment : [for var_name, val in var.app.env_vars : map("name", var_name, "value", val)]
    secrets : [for secret_name, secret_from in var.app.secrets : { name : secret_name, valueFrom : secret_from }]
  }])

  requires_compatibilities = ["FARGATE"]

  cpu    = var.app.cpu_credits
  memory = var.app.memory_megabytes

  tags = local.base_tags
}
