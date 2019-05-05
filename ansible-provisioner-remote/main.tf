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
      port_range       = "80"
      source_addresses = ["${var.source_range}"]
    },
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["${var.source_range}"]
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

resource "digitalocean_droplet" "webserver" {
  image              = "${var.image}"
  name               = "webserver"
  region             = "${var.region}"
  size               = "${var.size}"
  private_networking = true
  tags               = ["${digitalocean_tag.webserver.id}"]
  ssh_keys           = ["${var.ssh_fingerprint}"]

  # Define provisioners connection config
  connection {
    host        = "${digitalocean_droplet.webserver.ipv4_address}"
    type        = "ssh"
    user        = "root"
    timeout     = "1m"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "yum update -yqq",
      "yum install -yqq epel-release",
      "yum install -yqq python-pip git",
      "pip install -U pip six setuptools",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "pip install ansible==2.7.10",
    ]
  }

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

    remote {
      use_sudo     = false
      skip_install = true
      skip_cleanup = true
    }
  }
}
