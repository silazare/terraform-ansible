# Provider description
provider "google" {
  version = "~> 2.12"
  project = var.project
  region  = var.region
  zone    = var.zone
}

# VPC description
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "firewall_ssh" {
  name        = "terraform-network-ssh"
  network     = google_compute_network.vpc_network.self_link
  description = "Allow SSH for webservers"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.source_ip]

  target_tags = ["webserver", "lb"]
}

resource "google_compute_firewall" "firewall_http" {
  name        = "terraform-network-http-lb"
  network     = google_compute_network.vpc_network.self_link
  description = "Allow HTTP from load-balancer to all"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [var.source_ip]

  target_tags = ["lb"]
}

resource "google_compute_firewall" "firewall_webserver" {
  name        = "terraform-network-http-webserver"
  network     = google_compute_network.vpc_network.self_link
  description = "Allow HTTP from webservers to load-balancer"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = ["lb"]

  target_tags = ["webserver"]
}

# VM instance description
resource "google_compute_instance" "webserver" {
  name         = "webserver-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone
  count        = var.node_count

  metadata = {
    sshKeys = "${var.remote_user}:${file(var.public_key_path)}"
  }

  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }

  tags = ["webserver"]
}

resource "google_compute_instance" "load_balancer" {
  name         = "load-balancer"
  machine_type = var.machine_type
  zone         = var.zone
  count        = 1

  metadata = {
    sshKeys = "${var.remote_user}:${file(var.public_key_path)}"
  }

  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }

  tags = ["lb"]
}

