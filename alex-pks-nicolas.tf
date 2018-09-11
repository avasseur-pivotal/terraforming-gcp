// ***** FOR EACH PKS xyz instance

// Static IP address for forwarding rule
resource "google_compute_address" "cf-pks-xyznicolas" {
  name = "${var.env_name}-cf-pks-xyznicolas"
}

// TCP target pool
resource "google_compute_target_pool" "cf-pks-xyznicolas" {
  name = "${var.env_name}-cf-pks-xyznicolas"
  instances = [ "europe-west1-b/vm-af13a352-162e-4883-58c9-24985c09bfa7" ]
}

// TCP forwarding rule
resource "google_compute_forwarding_rule" "cf-pks-xyznicolas" {
  name        = "${var.env_name}-cf-pks-xyznicolas"
  target      = "${google_compute_target_pool.cf-pks-xyznicolas.self_link}"
  port_range  = "8443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-pks-xyznicolas.address}"
}

resource "google_dns_record_set" "wildcard-pks-dns-xyznicolas" {
  name = "nicolas.${google_dns_managed_zone.env_dns_zone_pks.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.env_dns_zone_pks.name}"

  rrdatas = ["${google_compute_address.cf-pks-xyznicolas.address}"]
}
