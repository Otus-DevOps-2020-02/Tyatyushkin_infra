resource "google_compute_instance" "db" {
  name = "reddit-db"
  machine_type = "g1-small"
  zone = var.zone
  tags = ["reddit-db"]
  boot_disk {
    initialize_params {
      image = var.db_disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    # путь до публичного ключа
    ssh-keys = "masterplan:${file(var.public_key_path)}"
  }

 connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = "masterplan"
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    content     = templatefile("${path.module}/files/mongod.conf.tmpl", { db_ip = self.network_interface.0.network_ip})
    destination = "/tmp/mongod.conf"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }

 }
resource "google_compute_firewall" "firewall_mongo" {
  name = "allow-mongo-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports = ["27017"]
  }
  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
