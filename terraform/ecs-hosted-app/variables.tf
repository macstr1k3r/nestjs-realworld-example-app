variable "base_domain" {
  type        = string
  description = <<desc
    The base domain for this environment
    usually follows the convention of "<env>.<productDomain>.<com>"
  desc
}

variable "product_name" {
  type = string
}

variable "app" {
  type = object({
    name         = string,
    traffic_port = number,

    cpu_credits      = string,
    memory_megabytes = string,

    subnet_ids = list(string)

    env_vars = map(string)
    secrets  = map(string)

    desired_count            = number
  })

  description = <<desc
  {
    name: The name of the app, will be used to name most resources
    traffic_port: The TCP port the service is listening to

    cpu_credits: AWS CPU credits, 1024==1vCPU
    memory_megabytes: RAM in MB

    subnet_ids: a list of subnetIds that this service will be deployed to

    env_vars: a map of environment variables to inject to the container
    secrets: a map of secrets to inject as environment variables.
          map key maps to env var name
          map value maps to valueFrom. can be Parameter Store param name or Secrets Manager secret arn

    desired_count: how many instances of the container you want as a default.
      note: this might colide with autoscaling.min_capacity. if autoscaling is enabled, these are best to be equal.
  }
  desc
}

variable "cluster" {
  type = object({
    id   = string
    name = string
  })

  description = <<desc
  {
    id: the id of the cluster in which to deploy
    name: the name of the cluster in which to deploy
  }
  desc
}

variable "alb" {
  type = object({
    id           = string
    listener_arn = string
    sg_id        = string
  })

  description = <<desc
  {
    id: the id of the alb to use
    listener_arn: the arn of the alb listener to use
    sg_id: the security group applied to the alb, will be used as the source in SGs created for the APP
  }
  desc
}

variable "hostname_settings" {
  type = object({
    prefixes = list(string),
    domains  = list(string)
  })

  validation {
    condition = length(var.hostname_settings.prefixes) == 0 || length(var.hostname_settings.domains) == 0
    error_message = "Can't provide both prefixes and domains in hostname_settings."
  }

  description = <<desc
    A list of prefix for hostnames (values of the Host header), for which to accept reqeusts.

    A prefix for a hostname in our context means the <prefix> portion of the domain name formula.

    The domain name formula is <prefix>.<environment>.<base_domain>
    
    Use case: 
    Web apps are on a different domain than the api load balancer(hosted in ecs).
    To avoid cors web apps often expose the api on `/api`, via CloudFront or some other reverse-proxy
    in this case the host-header has the value of the domain of the web-app, not the API. 
    this variable solves this case.
  desc
}

variable "ecr_repo_settings" {
  type = object({
    create_ecr_repository      = bool
    existing_repository_to_use = string
  })

  default = {
    create_ecr_repository      = true
    existing_repository_to_use = ""
  }

  description = <<desc
    create_ecr_repository: "Controls weather we provision an ecr repository or no. If you choose to use an existing repo, provide it via `docker_repository`"
    existing_repository_to_user: "An optional variable which should be provided in case `create_ecr_repository` is set to false"
  desc
}

variable "healthcheck_settings" {
  type = object({
    path     = string
    interval = number
  })

  default = {
    path     = "/health"
    interval = 30
  }

  description = <<desc
    Health check settings.
    The application should implement an HTTP endpoint which will report the service health to AWS.
    The path for this endpoint is configurable via the `path` property

    `interval` control how often(in seconds) does AWS query the health-check endpoint.

    Note that the timeout of the health-check endpoint is calculated by the formula floor(interval / 2)
  desc
}

variable "autoscaling" {
  type = object({
    min_capacity = number
    max_capacity = number

    cpu_target    = number
    memory_target = number
  })

  default = {
    min_capacity = 1
    max_capacity = 5

    cpu_target    = 70
    memory_target = 70
  }

  description = <<desc
    configuration for autoscaling the application
  desc
}

variable "failure_notifications" {
  type = object({
    enabled            = bool
    destination_emails = set(string)
  })

  default = {
    enabled            = false
    destination_emails = []
  }

  description = <<desc
    Enables or disables failure notifications.

    Failure notifiations are sent out via email whenever a container instance fails unexpectedly.
    In cases when a container instance is stopped in a controlled manner (ex: during deployments), notifications aren't sent.
  desc
}
