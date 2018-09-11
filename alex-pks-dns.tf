resource "google_dns_record_set" "wildcard-pks-dns" {
  name = "*.${google_dns_managed_zone.env_dns_zone_pks.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.env_dns_zone_pks.name}"

  rrdatas = ["${google_compute_address.cf-pks-api.address}"]
}
