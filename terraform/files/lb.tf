resource "google_compute_target_pool" "reddit-app-pool" {
  name        = "instance-pool"
  description = "reddit-app pool"

  instances = [
    "${google_compute_instance.app.*.self_link}",
  ]

  health_checks = [
    "${google_compute_http_health_check.default.name}",
  ]
}

resource "google_compute_http_health_check" "default" {
  name               = "default"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_forwarding_rule" "reddit-app-balancer" {
  name   = "reddit-app-balancer-rule"
  target = "${google_compute_target_pool.reddit-app-pool.self_link}"

  #port_range = "9292"
}
