# Output variables

output "droplet_name" {
  value = digitalocean_droplet.webserver.name
}

output "droplet_public_ip" {
  value = digitalocean_droplet.webserver.ipv4_address
}

output "droplet_private_ip" {
  value = digitalocean_droplet.webserver.ipv4_address_private
}

