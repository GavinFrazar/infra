resource "google_compute_instance" "controllers" {
  count = var.create ? 3 : 0

  name           = "${local.namespace}-controller-${count.index}"
  machine_type   = "e2-standard-2"
  can_ip_forward = true
  tags           = ["kube-controller"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  network_interface {
    network    = one(google_compute_network.kube[*].self_link)
    subnetwork = one(google_compute_subnetwork.kube[*].self_link)
    network_ip = "10.240.0.1${count.index}"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
}

resource "google_compute_instance" "workers" {
  count = var.create ? 3 : 0

  name           = "${local.namespace}-worker-${count.index}"
  machine_type   = "e2-standard-2"
  can_ip_forward = true
  tags           = ["kube-worker"]
  metadata = {
    pod-cidr = "10.200.${count.index}.0/24"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  network_interface {
    network    = one(google_compute_network.kube[*].self_link)
    subnetwork = one(google_compute_subnetwork.kube[*].self_link)
    network_ip = "10.240.0.2${count.index}"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
}
