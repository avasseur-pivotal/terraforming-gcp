// ***** FOR EACH PKS xyz instance

// Static IP address for forwarding rule
resource "google_compute_address" "cf-pks-xyzmohamed" {
  name = "${var.env_name}-cf-pks-xyzmohamed"
}

// TCP target pool
resource "google_compute_target_pool" "cf-pks-xyzmohamed" {
  name = "${var.env_name}-cf-pks-xyzmohamed"
  instances = [ "europe-west1-b/vm-9a958f58-9cfb-466e-5d79-d29ba8d61869" ]
}

// TCP forwarding rule
resource "google_compute_forwarding_rule" "cf-pks-xyzmohamed" {
  name        = "${var.env_name}-cf-pks-xyzmohamed"
  target      = "${google_compute_target_pool.cf-pks-xyzmohamed.self_link}"
  port_range  = "8443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.cf-pks-xyzmohamed.address}"
}

/*
// Mohamed is managing with his own DNS
resource "google_dns_record_set" "wildcard-pks-dns-xyzmohamed" {
  name = "c3.pks.${google_dns_managed_zone.env_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  rrdatas = ["${google_compute_address.cf-pks-xyzmohamed.address}"]
}
*/
