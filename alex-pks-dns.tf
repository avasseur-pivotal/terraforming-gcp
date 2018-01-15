resource "google_dns_record_set" "wildcard-pks-dns" {
  name = "*.pks.${google_dns_managed_zone.env_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  rrdatas = ["${google_compute_address.cf-pks-api.address}"]
}
