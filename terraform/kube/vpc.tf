resource "google_compute_network" "kube" {
  name                    = "${local.namespace}-net"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kube" {
  name          = "${local.namespace}-subnet"
  network       = google_compute_network.kube.self_link
  ip_cidr_range = "10.240.0.0/24"
}

resource "google_compute_firewall" "allow_internal" {
  name      = "${local.namespace}-allow-internal"
  network   = google_compute_network.kube.self_link
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
  name      = "${local.namespace}-allow-external"
  network   = google_compute_network.kube.self_link
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
  name = "${local.namespace}-load-balancer"
}
