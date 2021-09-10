
resource "aws_ecr_repository" "nrw" {
  name                 = "nrw-app"
  image_tag_mutability = "IMMUTABLE"
}
