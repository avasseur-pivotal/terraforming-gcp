variable "bastion_image_url" {
  type        = "string"
  description = "location of ops manager image on google cloud storage"
}

resource "google_compute_address" "bastion-ip" {
  name = "${var.env_name}-bastion-ip"
}

resource "google_compute_image" "bastion-image" {
  name           = "${var.env_name}-bastion-image"
  create_timeout = 20

  raw_disk {
    source = "${var.bastion_image_url}"
  }
}

resource "google_compute_instance" "bastion" {
  name           = "${var.env_name}-bastion"
  machine_type   = "${var.opsman_machine_type}"
  zone           = "${element(var.zones, 1)}"
  create_timeout = 10
  # keep this tag to have same firewall rule as OpsManager
  tags           = ["${var.env_name}-ops-manager-external"]

  boot_disk {
    initialize_params {
#     image = "${google_compute_image.ops-manager-image.self_link}"
      image = "${google_compute_image.bastion-image.self_link}"
      size  = 50
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.management-subnet.name}"

    access_config {
      nat_ip = "${google_compute_address.bastion-ip.address}"
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

resource "google_dns_record_set" "bastion-dns" {
  name = "bastion.${google_dns_managed_zone.env_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.env_dns_zone.name}"

  rrdatas = ["${google_compute_instance.bastion.network_interface.0.access_config.0.assigned_nat_ip}"]
}
