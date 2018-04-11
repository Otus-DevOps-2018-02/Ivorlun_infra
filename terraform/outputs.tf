output "apps_external_ips" {
  value = "${google_compute_instance.app.*.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "balancer_external_ip" {
  value = "${google_compute_forwarding_rule.reddit-app-balancer.ip_address}"
}
