// Allow access to PKS xyz master
resource "google_compute_firewall" "cf-pks-xyz" {
  name    = "${var.env_name}-cf-pks-xyz"
  network = "${google_compute_network.pcf-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  //target_tags = ["${var.env_name}-cf-pks-xyz"]
  // change underscore _ to dash -
  //target_tags = ["service-instance-dfe2cb21-d8e4-45f3-b8db-023802e41dac-master"]
  target_tags = ["master"]
}

// ***** FOR EACH PKS xyz instance

// Static IP address for forwarding rule
resource "google_compute_address" "cf-pks-xyzc3" {
  name = "${var.env_name}-cf-pks-xyzc3"
}

// TCP target pool
resource "google_compute_target_pool" "cf-pks-xyzc3" {
  name = "${var.env_name}-cf-pks-xyzc3"
  instances = [ "europe-west1-b/vm-3bdd2213-be1b-4cd7-5aed-6a27fedfab07" ]
}

// TCP forwarding rule
resource "google_compute_forwarding_rule" "cf-pks-xyzc3" {
  name        = "${var.env_name}-cf-pks-xyzc3"
  target      = "${google_compute_target_pool.cf-pks-xyzc3.self_link}"
  port_range  = "8443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-pks-xyzc3.address}"
}

resource "google_dns_record_set" "wildcard-pks-dns-xyzc3" {
  name = "c3.${google_dns_managed_zone.env_dns_zone_pks.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.env_dns_zone_pks.name}"

  rrdatas = ["${google_compute_address.cf-pks-xyzc3.address}"]
}
