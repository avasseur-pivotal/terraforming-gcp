/*
variable "opsman_image_url" {
  type        = "string"
  description = "location of ops manager image on google cloud storage"
}
*/

resource "google_compute_address" "opsman-pas-ip" {
  name = "${var.env_name}-opsman-pas-ip"
}

resource "google_compute_image" "opsman-pas-image" {
  name           = "${var.env_name}-opsman-pas-image"
  create_timeout = 20

  raw_disk {
    source = "${var.opsman-pas_image_url}"
  }
}

resource "google_compute_instance" "opsman-pas" {
  name           = "${var.env_name}-opsman-pas"
  machine_type   = "${var.opsman_machine_type}"
  zone           = "${element(var.zones, 1)}"
  create_timeout = 10
  # keep this tag to have same firewall rule as OpsManager
  tags           = ["${var.env_name}-ops-manager-external"]

  boot_disk {
    initialize_params {
#     image = "${google_compute_image.ops-manager-image.self_link}"
      image = "${google_compute_image.opsman-pas-image.self_link}"
      size  = 50
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.management-subnet.name}"

    access_config {
      nat_ip = "${google_compute_address.opsman-pas-ip.address}"
    }
  }

  service_account {
    email  = "${google_service_account.opsman_service_account.email}"
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys               = "${format("ubuntu:%s", tls_private_key.ops-manager.public_key_openssh)}"
    block-project-ssh-keys = "TRUE"
  }
}

resource "google_dns_record_set" "opsman-pas-dns" {
  name = "opsman-pas.${google_dns_managed_zone.env_dns_zone_toplevel.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.env_dns_zone_toplevel.name}"

  rrdatas = ["${google_compute_instance.opsman-pas.network_interface.0.access_config.0.assigned_nat_ip}"]
}
