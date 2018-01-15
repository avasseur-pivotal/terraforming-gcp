resource "google_compute_subnetwork" "pks-subnet" {
  name          = "${var.env_name}-pks-subnet"
  ip_cidr_range = "${var.pks_cidr}"
  network       = "${google_compute_network.pcf-network.self_link}"
  region        = "${var.region}"
}

