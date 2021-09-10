resource "aws_db_instance" "postgres" {
  engine         = "postgresql"
  version        = "12"
  instance_class = "db.t3.micro"
}
