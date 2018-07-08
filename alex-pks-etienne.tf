// ***** FOR EACH PKS xyz instance

// Static IP address for forwarding rule
resource "google_compute_address" "cf-pks-xyzetienne" {
  name = "${var.env_name}-cf-pks-xyzetienne"
}

// TCP target pool
resource "google_compute_target_pool" "cf-pks-xyzetienne" {
  name = "${var.env_name}-cf-pks-xyzetienne"
  instances = [ "europe-west1-b/vm-87d91744-1902-466b-561e-077499d11f65" ]
}

// TCP forwarding rule
resource "google_compute_forwarding_rule" "cf-pks-xyzetienne" {
  name        = "${var.env_name}-cf-pks-xyzetienne"
  target      = "${google_compute_target_pool.cf-pks-xyzetienne.self_link}"
  port_range  = "8443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-pks-xyzetienne.address}"
}

/*
// Etienne is managing with his own DNS
resource "google_dns_record_set" "wildcard-pks-dns-xyzetienne" {
  name = "c3.pks.${google_dns_managed_zone.env_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  rrdatas = ["${google_compute_address.cf-pks-xyzetienne.address}"]
}
*/
