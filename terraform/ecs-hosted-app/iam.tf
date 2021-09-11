resource "aws_iam_role" "app-ng" {
  name        = "${terraform.workspace}-${var.product_name}-${var.app.name}-ng-task-execution"
  description = "role assumed by the ecs/docker daemon"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Sid : ""
      Effect : "Allow",
      Principal : { Service : "ecs-tasks.amazonaws.com" },
      Action : "sts:AssumeRole",
    }]
  })

  tags = {
    "${var.product_name}:env" = terraform.workspace
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.app-ng.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_ecs_full_access" {
  role       = aws_iam_role.app-ng.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_ssm_ro" {
  role       = aws_iam_role.app-ng.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
