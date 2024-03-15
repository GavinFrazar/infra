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
  CREATE TABLE Singers (
    SingerId   INT64 NOT NULL,
    FirstName  STRING(1024),
    LastName   STRING(1024),
    SingerInfo BYTES(MAX),
    BirthDate  DATE,
  ) PRIMARY KEY(SingerId)
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
    CREATE TABLE Singers (
        BirthDate  TIMESTAMPTZ,
        SingerId   BIGINT PRIMARY KEY,
        FirstName  VARCHAR(1024),
        LastName   VARCHAR(1024),
        SingerInfo BYTEA
    );
    EOF
  ]
  database_dialect    = "POSTGRESQL"
  deletion_protection = false
}

resource "null_resource" "insert_googlesql_data" {
  count = var.create ? 1 : 0

  depends_on = [
    google_spanner_database.googlesql[0],
  ]

  provisioner "local-exec" {
    command = <<EOF
gcloud spanner databases execute-sql ${google_spanner_database.googlesql[0].name} \
  --instance=${google_spanner_instance.this[0].name} \
  --sql="INSERT INTO Singers (SingerId, FirstName, LastName) VALUES
        (1, 'Adele', 'Adkins'),
        (2, 'Taylor', 'Swift')"
EOF
  }
}

resource "null_resource" "insert_postgresql_data" {
  count = var.create ? 1 : 0

  depends_on = [
    google_spanner_database.postgresql,
  ]

  provisioner "local-exec" {
    command = <<EOF
gcloud spanner databases execute-sql ${google_spanner_database.postgresql[0].name} \
  --instance=${google_spanner_instance.this[0].name} \
  --sql="INSERT INTO Singers (SingerId, FirstName, LastName) VALUES
        (1, 'Adele', 'Adkins'),
        (2, 'Taylor', 'Swift')"
EOF
  }
}
