

resource "aws_db_subnet_group" "ptfe" {
  name_prefix = "${var.namespace}-subnetg"
  description = "${var.namespace}-db-subnet-group"
  subnet_ids  = aws_subnet.tfe_subnet.*.id
}

resource "random_password" "db_password" {
  length = 16
  special = true
  override_special = "/@"
}

resource "aws_db_instance" "ptfe" {
  allocated_storage         = var.database_storage
  engine                    = "postgres"
  engine_version            = "11.6"
  instance_class            = var.database_instance_class
  identifier                = "${var.namespace}-db-instance"
  name                      = "${var.namespace}pes"
  storage_type              = "gp2"
  username                  = var.database_username
  password                  = random_password.db_password.result
  db_subnet_group_name      = aws_db_subnet_group.ptfe.id
  
  vpc_security_group_ids    = [aws_security_group.tfe_sg.id]
  # If you are just testing or doing POC, uncomment line
  # with skip_final_snapshot and comment out final_snapshot_identifier
  skip_final_snapshot       = "true"
  #final_snapshot_identifier = "${var.namespace}-db-instance-final-snapshot"
}


