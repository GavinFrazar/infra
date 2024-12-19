locals {
  teleport_agent_kube_namespace = "teleport-agent"
  teleport_agent_kube_sa        = "teleport-agent"
  teleport_agent_workload_id = (
    "principalSet://iam.googleapis.com/projects/${var.project.number}/locations/global/workloadIdentityPools/${var.project.id}.svc.id.goog/namespace/${local.teleport_agent_kube_namespace}"
  )
  teleport_agent_gke_sa_id = "${var.project.id}.svc.id.goog[${local.teleport_agent_kube_namespace}/${local.teleport_agent_kube_sa}]"

  spanner_impersonators = concat(
    var.trusted_impersonators,
    google_service_account.gcloud_controller[*].member,
    google_service_account.spanner_controller[*].member,
  )

  spanner_instance_names = toset(compact(var.spanner_instance_names))
}
