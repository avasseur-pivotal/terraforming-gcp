// Allow access to PKS xyz master
resource "google_compute_firewall" "cf-pks-xyz" {
  name    = "${var.env_name}-cf-pks-xyz"
  network = "${google_compute_network.pcf-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  //target_tags = ["${var.env_name}-cf-pks-xyz"]
  target_tags = ["service-instance-71326d2b-4d2b-4a9d-90c1-ea44fe8b5213-master"]
}

// ***** FOR EACH PKS xyz instance

// Static IP address for forwarding rule
resource "google_compute_address" "cf-pks-xyzc3" {
  name = "${var.env_name}-cf-pks-xyzc3"
}

// TCP target pool
resource "google_compute_target_pool" "cf-pks-xyzc3" {
  name = "${var.env_name}-cf-pks-xyzc3"
  instances = [ "europe-west1-b/vm-5f712856-06bd-4827-4b92-3662576c571f" ]
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
  name = "c3.pks.${google_dns_managed_zone.env_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  rrdatas = ["${google_compute_address.cf-pks-xyzc3.address}"]
}
