// Allow access to PKS API router
resource "google_compute_firewall" "cf-pks-api" {
  name    = "${var.env_name}-cf-pks-api"
  network = "${google_compute_network.pcf-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["80-65535"]
  }

  target_tags = ["${var.env_name}-cf-pks-api"]
}

// Static IP address for forwarding rule
resource "google_compute_address" "cf-pks-api" {
  name = "${var.env_name}-cf-pks-api"
}

// Health check
/*
resource "google_compute_http_health_check" "cf-tcp" {
  name                = "${var.env_name}-cf-tcp"
  port                = 80
  request_path        = "/health"
  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 10
  unhealthy_threshold = 2
}
*/

// TCP target pool
resource "google_compute_target_pool" "cf-pks-api" {
  name = "${var.env_name}-cf-pks-api"

//  health_checks = [
//    "${google_compute_http_health_check.cf-tcp.name}",
//  ]
}

// TCP forwarding rule
resource "google_compute_forwarding_rule" "cf-pks-api" {
  name        = "${var.env_name}-cf-pks-api"
  target      = "${google_compute_target_pool.cf-pks-api.self_link}"
  port_range  = "80-65535"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-pks-api.address}"
}
