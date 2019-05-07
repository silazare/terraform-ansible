# Main resources description
provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_tag" "webserver" {
  name = "webserver"
}

resource "digitalocean_firewall" "webserver" {
  name = "webserver"

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["${var.source_range}"]
    },
    {
      protocol                  = "tcp"
      port_range                = "80"
      source_load_balancer_uids = ["${digitalocean_loadbalancer.loadbalancer.id}"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "udp"
      port_range            = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "tcp"
      port_range            = "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]

  tags = [
    "${digitalocean_tag.webserver.id}",
  ]
}

resource "digitalocean_loadbalancer" "loadbalancer" {
  name   = "loadbalancer"
  region = "nyc3"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  healthcheck {
    port     = 80
    protocol = "http"
    path     = "/"
  }

  droplet_tag = "${digitalocean_tag.webserver.id}"
}

resource "digitalocean_droplet" "webserver" {
  image              = "${var.image}"
  name               = "webserver-${count.index+1}"
  region             = "${var.region}"
  size               = "${var.size}"
  private_networking = true
  tags               = ["${digitalocean_tag.webserver.id}"]
  ssh_keys           = ["${var.ssh_fingerprint}"]
  count              = "${var.node_count}"

  # Ansible local provisioner
  provisioner "ansible" {
    plays {
      playbook = {
        file_path = "../ansible/provision_inline.yml"
      }

      enabled  = true
      diff     = false
      vault_id = ["../ansible/.vault_pass"]
    }

    ansible_ssh_settings {
      connect_timeout_seconds              = 10
      connection_attempts                  = 10
      ssh_keyscan_timeout                  = 60
      insecure_no_strict_host_key_checking = true
    }
  }
}
