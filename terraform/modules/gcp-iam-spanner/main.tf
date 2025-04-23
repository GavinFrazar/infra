# Create service accounts.

resource "google_service_account" "gcloud_controller" {
  count = var.create ? 1 : 0

  account_id  = "${var.namespace}-gcloud-controller"
  description = "Controlling service account to impersonate other service accounts for gcloud cli."
}

resource "google_service_account" "spanner_controller" {
  count = var.create ? 1 : 0

  account_id  = "${var.namespace}-spanner-controller"
  description = "Controlling service account to fetch spanner access tokens."
}

resource "google_service_account" "spanner_admin_user" {
  count = var.create ? 1 : 0

  account_id  = "${var.namespace}-spanner-admin-user"
  description = "Target service account to act as a Spanner admin."
}

resource "google_service_account" "spanner_user" {
  count = var.create ? 1 : 0

  account_id  = "${var.namespace}-spanner-user"
  description = "Target service account to act as a Spanner user."
}

resource "google_service_account" "spanner_role_user" {
  count = var.create ? 1 : 0

  account_id  = "${var.namespace}-spanner-role-user"
  description = "Target service account to act as a Spanner role."
}

# Grant permissions

# Step 1/9. Create a service account for the Teleport Database Service
resource "google_service_account" "db_agent" {
  account_id  = "gavin-teleport-db-agent"
  description = "GCP IAM service account for a Teleport database agent."
}

# This is a "project" IAM role grant.
# It grants a role at the project scope.
# It does not appear possible to grant a role at a more specific scope than
# "project" (unlike how, for some reason, you can grant IAM roles for GCP Spanner at individual instance scope).
resource "google_project_iam_member" "allow_db_agent_to_manage_certs" {
  project = var.project.id
  role    = "roles/cloudsql.client"
  member  = google_service_account.db_agent.member
}

resource "google_project_iam_member" "allow_db_agent_to_describe_users" {
  project = var.project.id
  role    = "roles/cloudsql.viewer"
  member  = google_service_account.db_agent.member
}

# Step 2/9. Create a service account for a database user.
resource "google_service_account" "db_user" {
  account_id  = "gavin-teleport-gcp-sql-user"
  description = "GCP IAM service account for a GCP SQL database."
}

resource "google_project_iam_member" "allow_db_user_to_login_to_all_databases" {
  project = var.project.id
  role    = "roles/cloudsql.instanceUser"
  member  = google_service_account.db_user.member
}

# This is a "service_account" IAM role grant.
# It grants a role at the service account scope.
# The db_agent service account only needs to be able to impersonate the db_user
# service account.
resource "google_service_account_iam_member" "allow_db_agent_to_impersonate_db_user" {
  # grant the role at the db_user service account scope.
  service_account_id = google_service_account.db_user.name
  role               = "roles/iam.serviceAccountTokenCreator"
  # grant the role to the db_agent service account.
  member = google_service_account.db_agent.member
}

resource "google_project_iam_member" "impersonate_all" {
  count = var.create ? 1 : 0

  project = var.project.id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = one(google_service_account.gcloud_controller[*].member)
}

resource "google_project_iam_member" "test" {
  count = var.create ? 1 : 0

  project = var.project.id
  role    = "roles/compute.viewer"
  member  = one(google_service_account.spanner_user[*].member)
}

resource "google_spanner_instance_iam_binding" "admin_user" {
  for_each = var.create ? local.spanner_instance_names : []

  instance = each.key
  role     = "roles/spanner.databaseAdmin"
  members  = google_service_account.spanner_admin_user[*].member
}

resource "google_spanner_instance_iam_binding" "user" {
  for_each = var.create ? local.spanner_instance_names : []

  instance = each.key
  role     = "roles/spanner.databaseUser"
  members  = google_service_account.spanner_user[*].member
}

# TODO(gavin): grant roles/spanner.databaseRoleUser with a condition.
# See: https://cloud.google.com/spanner/docs/iam#roles
resource "google_spanner_instance_iam_binding" "role_user" {
  for_each = var.create ? local.spanner_instance_names : []

  instance = each.key
  role     = "roles/spanner.fineGrainedAccessUser"
  members  = google_service_account.spanner_role_user[*].member
}

# Grant impersonation permissions

resource "google_service_account_iam_binding" "impersonate_gcloud_controller" {
  count = var.create ? 1 : 0

  service_account_id = one(google_service_account.gcloud_controller[*].name)
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${local.teleport_agent_gke_sa_id}"
  ]
}

resource "google_service_account_iam_binding" "impersonate_spanner_controller" {
  count = var.create ? 1 : 0

  service_account_id = one(google_service_account.spanner_controller[*].name)
  role               = "roles/iam.serviceAccountTokenCreator"
  members = concat(
    var.trusted_impersonators,
    google_service_account.gcloud_controller[*].member,
  )
}

resource "google_service_account_iam_binding" "impersonate_spanner_admin_user" {
  count = var.create ? 1 : 0

  service_account_id = one(google_service_account.spanner_admin_user[*].name)
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = local.spanner_impersonators
}

resource "google_service_account_iam_binding" "impersonate_spanner_user" {
  count = var.create ? 1 : 0

  service_account_id = one(google_service_account.spanner_user[*].name)
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = local.spanner_impersonators
}

resource "google_service_account_iam_binding" "impersonate_spanner_role_user" {
  count = var.create ? 1 : 0

  service_account_id = one(google_service_account.spanner_role_user[*].name)
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = local.spanner_impersonators
}
