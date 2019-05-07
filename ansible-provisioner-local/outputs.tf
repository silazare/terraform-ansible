# Output variables

output "Droplets Name" {
  value = "${digitalocean_droplet.webserver.*.name}"
}

output "Droplets Public IP" {
  value = "${digitalocean_droplet.webserver.*.ipv4_address}"
}

output "Droplets Private IP" {
  value = "${digitalocean_droplet.webserver.*.ipv4_address_private}"
}

output "Load Balancer IP" {
  value = "${digitalocean_loadbalancer.loadbalancer.ip}"
}
