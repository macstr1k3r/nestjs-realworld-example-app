data "aws_subnet_ids" "nrw_public_subnets" {
  vpc_id = aws_vpc.nrw.id

  tags = {
    "subnet_type" = "public"
  }
}

module "nrw-app" {
  source = "../ecs-hosted-app"

  app = {
    name         = "nrw",
    traffic_port = 80

    cpu_credits      = "512"
    memory_megabytes = "1024"

    subnet_ids = data.aws_subnet_ids.nrw_public_subnets.ids

    env_vars = {
      NRW_DB_ENDPOINT = aws_db_instance.postgres.endpoint
    }

    secrets = {
    }

    desired_count = 1
  }

  cluster = {
    id   = aws_ecs_cluster.nrw.id
    name = aws_ecs_cluster.nrw.name
  }

  alb = {
    id           = aws_alb.nrw_alb.id
    listener_arn = aws_alb_listener.https_listener.arn
    sg_id        = aws_security_group.alb_sg.id
  }

  base_domain  = var.base_domain
  product_name = "nrw"

  hostname_settings = {
    prefixes = []
    domains  = []
  }

  healthcheck_settings = {
    path     = "/.well-known/apollo/server-health"
    interval = 30
  }
}
