# Output variables

output "droplets_name" {
  value = digitalocean_droplet.webserver.*.name
}

output "droplets_public_ips" {
  value = digitalocean_droplet.webserver.*.ipv4_address
}

output "droplets_private_ips" {
  value = digitalocean_droplet.webserver.*.ipv4_address_private
}

output "load_balancer_ip" {
  value = digitalocean_loadbalancer.loadbalancer.ip
}

