# Output variables
output "Webservers NAT IPs" {
  value = "${google_compute_instance.webserver.*.network_interface.0.access_config.0.nat_ip}"
}

output "Webservers Internal IPs" {
  value = "${google_compute_instance.webserver.*.network_interface.0.network_ip}"
}

output "LoadBalancer NAT IP" {
  value = "${google_compute_instance.load_balancer.network_interface.0.access_config.0.nat_ip}"
}
