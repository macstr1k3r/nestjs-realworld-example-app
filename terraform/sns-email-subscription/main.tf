data "aws_region" "current" {}

resource "null_resource" "email_subscription" {
  depends_on = [var.topic_arn]

  provisioner "local-exec" {
    command = "aws sns subscribe --region=${data.aws_region.current.name} --topic-arn ${var.topic_arn} --protocol email --notification-endpoint ${var.email_address}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Destroy-time provisioner. not yet implemented. would need list subscriptions + unsubscribe'"
  }

  triggers = {
    email_id  = var.email_address
    topic_arn = var.topic_arn
  }
}
