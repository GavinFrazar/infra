resource "google_compute_network" "kube" {
  count = var.create ? 1 : 0

  name                    = "${local.namespace}-net"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kube" {
  count = var.create ? 1 : 0

  name          = "${local.namespace}-subnet"
  network       = one(google_compute_network.kube[*].self_link)
  ip_cidr_range = "10.240.0.0/24"
}

resource "google_compute_firewall" "allow_internal" {
  count = var.create ? 1 : 0

  name      = "${local.namespace}-allow-internal"
  network   = one(google_compute_network.kube[*].self_link)
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"]
}

resource "google_compute_firewall" "allow_external" {
  count = var.create ? 1 : 0

  name      = "${local.namespace}-allow-external"
  network   = one(google_compute_network.kube[*].self_link)
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["${var.access_from_ip}/32"]
}

resource "google_compute_address" "load_balancer" {
  count = var.create ? 1 : 0

  name = "${local.namespace}-load-balancer"
}
