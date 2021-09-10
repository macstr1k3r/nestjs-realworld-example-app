resource "aws_ecr_repository" "app-ng" {

  name = "${var.product_name}-${var.app.name}-ng-${terraform.workspace}"

  image_tag_mutability = "MUTABLE"

  tags = local.base_tags
}
