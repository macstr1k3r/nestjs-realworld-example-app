locals {
  monitor_failures = var.failure_notifications.enabled == true
}

data "aws_caller_identity" "current" {}


data "aws_iam_policy_document" "sns_topic_policy" {
  count     = local.monitor_failures == true ? 1 : 0
  policy_id = "__default_policy_ID"

  statement {
    sid     = "allow_publish_events"
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }

    resources = [aws_sns_topic.failures[count.index].arn]
  }
}

resource "aws_sns_topic" "failures" {
  count = local.monitor_failures == true ? 1 : 0
  name  = "${var.product_name}-${terraform.workspace}-${var.app.name}-app-failure-notifications"

  tags = local.base_tags
}

resource "aws_sns_topic_policy" "default" {
  count = local.monitor_failures == true ? 1 : 0
  arn   = aws_sns_topic.failures[count.index].arn

  policy = data.aws_iam_policy_document.sns_topic_policy[count.index].json
}

module "sns-email-subscription" {
  source = "../sns-email-subscription"

  for_each = var.failure_notifications.destination_emails

  topic_arn     = aws_sns_topic.failures[0].arn
  email_address = each.value
}

resource "aws_cloudwatch_event_rule" "task_failures" {
  count = local.monitor_failures == true ? 1 : 0

  name        = "${var.product_name}-${terraform.workspace}-${var.app.name}-app-failures"
  description = "Send notifications to SNS(email) in case of cotnainer failures"
  event_pattern = jsonencode({
    source : ["aws.ecs"],
    detail-type : ["ECS Task State Change"],
    detail : {
      lastStatus : ["STOPPED"],
      group : ["service:${local.ecs_service_name}"],
      clusterArn : [var.cluster.id]
    }
  })

  tags = local.base_tags
}

resource "aws_cloudwatch_event_target" "task_failures" {
  count = local.monitor_failures == true ? 1 : 0

  depends_on = [aws_cloudwatch_event_rule.task_failures[0]]

  arn  = aws_sns_topic.failures[count.index].arn
  rule = "${var.product_name}-${terraform.workspace}-${var.app.name}-app-failures"

  input_transformer {
    input_paths = {
      "eventTime"         = "$.time",
      "availabilityZone"  = "$.detail.availabilityZone",
      "createdAt"         = "$.detail.createdAt",
      "pullStartedAt"     = "$.detail.pullStartedAt",
      "pullStoppedAt"     = "$.detail.pullStoppedAt",
      "startedAt"         = "$.detail.startedAt",
      "stoppedAt"         = "$.detail.stoppedAt",
      "taskArn"           = "$.detail.taskArn",
      "taskDefinitionArn" = "$.detail.taskDefinitionArn",
      "stoppedReason"     = "$.detail.stoppedReason"
    }


    input_template = <<desc
"The application ${var.app.name} on ${terraform.workspace} has failed."
"stoppepdReason:        <stoppedReason>"
"eventTime:             <eventTime>"
"availabilityZone:      <availabilityZone>"
"createdAt:             <createdAt>"
"stoppedAt:             <stoppedAt>"
"stoppedReason:         <stoppedReason>"
"taskDefinitionArn:     <taskDefinitionArn>"
desc

  }
}
