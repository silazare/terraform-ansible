# Output variables

output "Droplet Name" {
  value = "${digitalocean_droplet.webserver.name}"
}

output "Droplet Public IP" {
  value = "${digitalocean_droplet.webserver.ipv4_address}"
}

output "Droplet Private IP" {
  value = "${digitalocean_droplet.webserver.ipv4_address_private}"
}
