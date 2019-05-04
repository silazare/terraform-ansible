# Provider description
provider "google" {
#  credentials = "${file("../../secrets/account-thrashingcode.json")}"
  project = "${var.project}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

# VPC description
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "firewall_ssh" {
  name        = "terraform-network-allow-ssh"
  network     = "${google_compute_network.vpc_network.self_link}"
  description = "Allow SSH for webservers"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.source_ip}"]

  target_tags = ["webserver"]
}

resource "google_compute_firewall" "firewall_http" {
  name        = "terraform-network-allow-http"
  network     = "${google_compute_network.vpc_network.self_link}"
  description = "Allow HTTP for webservers"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["${var.source_ip}"]

  target_tags = ["webserver"]
}

# VM instance description
resource "google_compute_instance" "webserver" {
  name         = "webserver"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"

  metadata {
    sshKeys = "${var.remote_user}:${file(var.public_key_path)}"
  }

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "${google_compute_network.vpc_network.self_link}"
    access_config = {}
  }

  tags = ["webserver"]

  # Provisioners description
  provisioner "remote-exec" {
    inline = ["echo 'Connected!'"]

    connection {
      type        = "ssh"
      user        = "${var.remote_user}"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "local-exec" {
    command = "cd ../ansible; ansible-playbook -u ${var.remote_user} -i '${self.network_interface.0.access_config.0.nat_ip},' --private-key ${var.private_key_path} provision_inline.yml --vault-password-file .vault_pass"
  }
}
