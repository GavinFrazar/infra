# Create service accounts.

resource "google_service_account" "controller" {
  count = var.create ? 1 : 0

  account_id  = "${var.namespace}-spanner-controller"
  description = "Controlling service account to fetch spanner access tokens."
}

resource "google_service_account" "admin_user" {
  count = var.create ? 1 : 0

  account_id  = "${var.namespace}-spanner-admin-user"
  description = "Target service account to act as a Spanner admin."
}

resource "google_service_account" "user" {
  count = var.create ? 1 : 0

  account_id  = "${var.namespace}-spanner-user"
  description = "Target service account to act as a Spanner user."
}

resource "google_service_account" "role_user" {
  count = var.create ? 1 : 0

  account_id  = "${var.namespace}-spanner-role-user"
  description = "Target service account to act as a Spanner role."
}

# Grant roles to services accounts.

resource "google_spanner_instance_iam_binding" "admin_user" {
  for_each = var.create ? toset(compact(var.spanner_instance_names)) : []

  instance = each.key
  role     = "roles/spanner.databaseAdmin"
  members  = google_service_account.admin_user[*].member
}

resource "google_spanner_instance_iam_binding" "user" {
  for_each = var.create ? toset(compact(var.spanner_instance_names)) : []

  instance = each.key
  role     = "roles/spanner.databaseUser"
  members  = google_service_account.user[*].member
}

# TODO(gavin): grant roles/spanner.databaseRoleUser with a condition.
# See: https://cloud.google.com/spanner/docs/iam#roles
resource "google_spanner_instance_iam_binding" "role_user" {
  for_each = var.create ? toset(compact(var.spanner_instance_names)) : []

  instance = each.key
  role     = "roles/spanner.fineGrainedAccessUser"
  members  = google_service_account.role_user[*].member
}

# Allow the controller service account to impersonate the others.

resource "google_service_account_iam_binding" "impersonate_controller" {
  count = var.create ? 1 : 0

  service_account_id = one(google_service_account.controller[*].name)
  role               = "roles/iam.serviceAccountTokenCreator"

  members = var.trusted_impersonators
}

resource "google_service_account_iam_binding" "impersonate_admin_user" {
  count = var.create ? 1 : 0

  service_account_id = one(google_service_account.admin_user[*].name)
  role               = "roles/iam.serviceAccountTokenCreator"

  members = google_service_account.controller[*].member
}

resource "google_service_account_iam_binding" "impersonate_user" {
  count = var.create ? 1 : 0

  service_account_id = one(google_service_account.user[*].name)
  role               = "roles/iam.serviceAccountTokenCreator"

  members = google_service_account.controller[*].member
}

resource "google_service_account_iam_binding" "impersonate_role_user" {
  count = var.create ? 1 : 0

  service_account_id = one(google_service_account.role_user[*].name)
  role               = "roles/iam.serviceAccountTokenCreator"

  members = google_service_account.controller[*].member
}
