
resource "aws_appautoscaling_target" "app-ng" {
  min_capacity = var.autoscaling.min_capacity
  max_capacity = var.autoscaling.max_capacity

  resource_id = "service/${var.cluster.name}/${aws_ecs_service.app-ng.name}"

  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "app-ng-cpu" {
  name        = "${terraform.workspace}-${var.app.name}-cpu-tracker"
  policy_type = "TargetTrackingScaling"

  resource_id        = aws_appautoscaling_target.app-ng.resource_id
  scalable_dimension = aws_appautoscaling_target.app-ng.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app-ng.service_namespace


  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = var.autoscaling.cpu_target
  }
}

resource "aws_appautoscaling_policy" "app-ng-memory" {
  name        = "${terraform.workspace}-${var.app.name}-memory-tracker"
  policy_type = "TargetTrackingScaling"

  resource_id        = aws_appautoscaling_target.app-ng.resource_id
  scalable_dimension = aws_appautoscaling_target.app-ng.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app-ng.service_namespace


  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = var.autoscaling.memory_target
  }
}
