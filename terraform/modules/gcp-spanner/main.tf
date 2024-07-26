resource "google_spanner_instance" "this" {
  count = var.create ? 1 : 0

  name         = "${var.namespace}-spanner"
  config       = "regional-us-central1"
  display_name = "${var.namespace}-spanner"
  # The minimum.
  # conflicts with num_nodes.
  # num_nodes=1 is equivalent to 1000 processing_units.
  processing_units = 100
  # delete all backups of this instance on destroy
  force_destroy = true
}

resource "google_spanner_database" "googlesql" {
  count = var.create ? 1 : 0

  instance = google_spanner_instance.this[0].name
  name     = "${var.namespace}-googlesql"
  ddl = [
    <<-EOF
  CREATE TABLE People (
    ID   INT64 NOT NULL,
    FirstName  STRING(1024),
    LastName   STRING(1024),
  ) PRIMARY KEY(ID)
  EOF
  ]
  database_dialect    = "GOOGLE_STANDARD_SQL"
  deletion_protection = false
}

resource "google_spanner_database" "postgresql" {
  count = var.create ? 1 : 0

  instance = google_spanner_instance.this[0].name
  name     = "${var.namespace}-postgresql"
  ddl = [
    <<-EOF
    CREATE TABLE People (
        ID   BIGINT PRIMARY KEY,
        FirstName  VARCHAR(1024),
        LastName   VARCHAR(1024)
    );
    EOF
  ]
  database_dialect    = "POSTGRESQL"
  deletion_protection = false
}
