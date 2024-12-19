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
