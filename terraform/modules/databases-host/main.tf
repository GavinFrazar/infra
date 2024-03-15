resource "aws_instance" "this" {
  count = var.create ? 1 : 0

  ami                         = var.ami_id
  associate_public_ip_address = true
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = aws_security_group.this[*].id
  key_name                    = var.access_key_pair_name

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
    kms_key_id            = one(aws_kms_key.this[*].arn)
  }

  tags = {
    Name = "${var.namespace}-databases-host"
  }
}

# KMS key used to encrypt AMI and Instance root block devices
resource "aws_kms_key" "this" {
  count = var.create ? 1 : 0

  description         = "Key used for encrypting instance root block device"
  key_usage           = "ENCRYPT_DECRYPT"
  enable_key_rotation = true
  policy              = try(data.aws_iam_policy_document.encryption_key_policy[0].json, "")

  tags = {
    Name = "${var.namespace}_databases_host"
  }
}

resource "aws_security_group" "this" {
  count = var.create ? 1 : 0

  name        = "${var.namespace}_databases_host"
  description = "allow self-hosted database and ssh access from my ip"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  count = var.create ? 1 : 0

  description       = "allow all egress"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = one(aws_security_group.this[*].id)
}

# resource "aws_vpc_security_group_ingress_rule" "allow_self" {
#   count = var.create ? 1 : 0

#   description       = "allow access from the ec2 instance itself"
#   cidr_ipv4         = try("${aws_instance.this[0].public_ip}/32", "")
#   ip_protocol       = "-1"
#   security_group_id = one(aws_security_group.this[*].id)
# }

resource "aws_vpc_security_group_ingress_rule" "allow_sg" {
  count = var.create ? 1 : 0

  description                  = "allow access from anything else in the security group"
  ip_protocol                  = "-1"
  referenced_security_group_id = one(aws_security_group.this[*].id)
  security_group_id            = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  count = var.create ? 1 : 0

  description       = "allow ssh from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_postgres" {
  count = var.create ? 1 : 0

  description       = "allow postgres from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_mysql" {
  count = var.create ? 1 : 0

  description       = "allow mysql from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_mariadb" {
  count = var.create ? 1 : 0

  description       = "allow mariadb (on 3307 because mysql is on 3306) from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 3307
  to_port           = 3307
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_mongodb" {
  count = var.create ? 1 : 0

  description       = "allow mongodb from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 27017
  to_port           = 27017
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_mongodb_replicaset" {
  count = var.create ? 1 : 0

  description       = "allow mongodb replicaset from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 27021
  to_port           = 27023
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_oracle" {
  count = var.create ? 1 : 0

  description       = "allow oracle from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 2484
  to_port           = 2484
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_cassandra" {
  count = var.create ? 1 : 0

  description       = "allow cassandra from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 9042
  to_port           = 9042
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_scylladb" {
  count = var.create ? 1 : 0

  description       = "allow scylladb (on 9043 because cassandra is on 9042) from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 9043
  to_port           = 9043
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_cockroach" {
  count = var.create ? 1 : 0

  description       = "allow cockroachdb from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 26257
  to_port           = 26257
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_clickhouse_http" {
  count = var.create ? 1 : 0

  description       = "allow clickhouse http from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 8443
  to_port           = 8443
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_clickhouse_native" {
  count = var.create ? 1 : 0

  description       = "allow clickhouse native from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 9440
  to_port           = 9440
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_elasticsearch" {
  count = var.create ? 1 : 0

  description       = "allow elasticsearch from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 9200
  to_port           = 9200
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_redis" {
  count = var.create ? 1 : 0

  description       = "allow redis from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 6379
  to_port           = 6379
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_redis_cluster" {
  count = var.create ? 1 : 0

  description       = "allow redis cluster (redis single node is on 6379) from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 7001
  to_port           = 7006
  security_group_id = one(aws_security_group.this[*].id)
}

resource "aws_vpc_security_group_ingress_rule" "allow_redis_cluster_bus" {
  count = var.create ? 1 : 0

  description       = "allow redis cluster bus from my ip"
  cidr_ipv4         = "${var.access_from_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 17001
  to_port           = 17006
  security_group_id = one(aws_security_group.this[*].id)
}
