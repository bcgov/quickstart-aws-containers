resource "aws_appautoscaling_target" "api_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_service.node_api_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "api_up" {
name            = "node-api-scale-up-${var.target_env}-${var.app_env}"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_service.node_api_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.api_target]
}
# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "api_down" {
name            = "node-api-scale-down-${var.target_env}-${var.app_env}"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_service.node_api_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.api_target]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "node_api_service_cpu_low" {
  alarm_name          = "wfnews_client_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.node_api_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.api_down.arn]

  tags = local.common_tags
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "wfnews_client_service_cpu_high" {
  alarm_name          = "wfnews_client_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "50"

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.node_api_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.api_up.arn]

  tags = local.common_tags
}