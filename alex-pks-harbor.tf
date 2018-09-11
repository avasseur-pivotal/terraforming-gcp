// Allow access to PKS HARBOR
resource "google_compute_firewall" "cf-pks-harbor" {
  name    = "${var.env_name}-cf-pks-harbor"
  network = "${google_compute_network.pcf-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  //target_tags = ["${var.env_name}-cf-pks-harbor"]
  // change underscore _ to dash -
  //target_tags = ["TODO"]
}

// ***** PKS harbor instance

// Static IP address for forwarding rule
resource "google_compute_address" "cf-pks-harbor" {
  name = "${var.env_name}-cf-pks-harbor"
}

// TCP target pool
resource "google_compute_target_pool" "cf-pks-harbor" {
  name = "${var.env_name}-cf-pks-harbor"
  //instances = [ ] // leave commented out - not just empty - BOSH will manage thru the tile
}

// TCP forwarding rule
resource "google_compute_forwarding_rule" "cf-pks-harbor" {
  name        = "${var.env_name}-cf-pks-harbor"
  target      = "${google_compute_target_pool.cf-pks-harbor.self_link}"
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-pks-harbor.address}"
}

resource "google_dns_record_set" "wildcard-pks-dns-harbor" {
  name = "harbor.${google_dns_managed_zone.env_dns_zone_pks.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.env_dns_zone_pks.name}"

  rrdatas = ["${google_compute_address.cf-pks-harbor.address}"]
}
