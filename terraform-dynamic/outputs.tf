# Output variables
output "webserver_nat_ips" {
  value = google_compute_instance.webserver.*.network_interface.0.access_config.0.nat_ip
}

output "webserver_internal_ip" {
  value = google_compute_instance.webserver.*.network_interface.0.network_ip
}

output "loadbalancer_nat_ip" {
  value = google_compute_instance.load_balancer[0].network_interface[0].access_config[0].nat_ip
}

