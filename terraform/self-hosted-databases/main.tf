resource "aws_instance" "databases" {
  count                       = var.ec2_instance_count
  ami                         = var.ami_id
  associate_public_ip_address = true
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.dev.id]
  key_name                    = var.access_keypair_name

  user_data = file("${path.module}/user_data")
  # restart instance if user_data file contents change
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 128 # GB
    encrypted             = true
    kms_key_id            = aws_kms_key.databases.arn
  }

  tags = var.additional_tags
}

# KMS key used to encrypt AMI and Instance root block devices
resource "aws_kms_key" "databases" {
  description         = "Key used for encrypting instance root block device"
  key_usage           = "ENCRYPT_DECRYPT"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.encryption_key_policy.json

  tags = var.additional_tags
}


resource "aws_security_group" "dev" {
  description = "allow self-hosted database and ssh access from my ip"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  description       = "allow all egress"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_self" {
  description       = "allow access from the ec2 instance itself"
  cidr_ipv4         = "${aws_instance.databases[0].public_ip}/32"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_sg" {
  description                  = "allow access from anything else in the security group"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.dev.id
  security_group_id            = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  description       = "allow ssh from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_postgres" {
  description       = "allow postgres from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  description       = "allow mysql from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_mariadb" {
  description       = "allow mariadb (on 3307 because mysql is on 3306) from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 3307
  to_port           = 3307
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_mongodb" {
  description       = "allow mongodb from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 27017
  to_port           = 27017
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_oracle" {
  description       = "allow oracle from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 2484
  to_port           = 2484
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_cassandra" {
  description       = "allow cassandra from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 9042
  to_port           = 9042
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_scylladb" {
  description       = "allow scylladb (on 9043 because cassandra is on 9042) from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 9043
  to_port           = 9043
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_cockroach" {
  description       = "allow cockroachdb from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 26257
  to_port           = 26257
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_clickhouse_http" {
  description       = "allow clickhouse http from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 8443
  to_port           = 8443
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_clickhouse_native" {
  description       = "allow clickhouse native from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 9440
  to_port           = 9440
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_elasticsearch" {
  description       = "allow elasticsearch from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 9200
  to_port           = 9200
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_redis" {
  description       = "allow redis from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 6379
  to_port           = 6379
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_redis_cluster" {
  description       = "allow redis cluster (redis single node is on 6379) from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 7001
  to_port           = 7006
  security_group_id = aws_security_group.dev.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_redis_cluster_bus" {
  description       = "allow redis cluster bus from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 17001
  to_port           = 17006
  security_group_id = aws_security_group.dev.id
}
