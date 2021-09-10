
resource "aws_cloudwatch_log_group" "app-ng" {
  name              = "${terraform.workspace}-${var.app.name}"
  retention_in_days = 60

  tags = local.base_tags
}
