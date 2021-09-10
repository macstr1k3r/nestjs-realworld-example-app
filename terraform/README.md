# IaC

This portion of the codebase contains terraform code which defines the infrastructure and services to run the application.

It is designed such that it addresses several things at least on a basic level, and other things(outlined below) were intentionally left out of scope.

### Design goals:

- reproducibility of deployments
- horizontal scaling
- load balancing
- self healing
- failure monitoring
- data center outage resilience
- configurability
- network level security

### Non-goals:
- regional outage resilience
- regulatory compliance
- reliability of the database deployment
	- mostly to not incur unwanted costs during development
- auditable activity logs
- many other things.



The implementation is structured in a way which shows some of the capabilities of `terraform`, namely support for modules, injection of variables, deploying the same code to multiple environments, etc.

The `ecs-hosted-app` module can be reused by many services to share a single ECS cluster.

Further code reuse can be achieved by extracting common components such as network constructs into a separate module.


## Architecture
The architecture chosen is a mix of serverless and more traditional technologies, with the goal of providing maximum flexibility while maintaining a reasonable level of operational overhead. 

Instead of providing a diagram of the high level architecture, for the sake of time and simplicity, the following section outlines it in word form.

The current shape of the platform is such that an `AWS Application Load Balancer` accepts all requests. It then forwards and balances them across a cluster of `containerized` Node.JS instances of the application. The *containers* are ran on `Fargate` which removes the operating system from the equation. The database is hosted by `AWS RDS` with the goal of reducing DB management overhead. An underlying network is provisioned which enables flexibility in further expanding the platform with both modern and legacy technologies.

Depending on requirements, the architecture can be evolved in any direction, flexibility, control, and cost effectiveness can be increased by further adopting traditional technologies. Observability can be increased by using more of what `CloudWatch` has to offer. Reactiveness can be achieved by composing existing event streams with `AWS Lambda` to interpret operational events for us, realtime processing of application log streams can preemptively detect runtime issues, and global performance and regional outage tolerance can be achieved by introducing `CloudFront` to the mix.