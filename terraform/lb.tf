
# Creation instance group
resource "google_compute_instance_group" "lb" {
  name        = "lbgroup"
  description = "load balancer group"
  zone        = var.zone
  instances = google_compute_instance.app[*].self_link
  named_port {
    name = "puma"
    port = "9292"
  }
}

# Configuring a firewall rule
resource "google_compute_firewall" "fw-allow-health-check" {
  name    = "lb-firewall"
  network = "default"

  allow {
    protocol = "tcp"
  }

  target_tags = ["allow-health-check"]
}

resource "google_compute_global_address" "lb-ipv4" {
  name = "lb-address"
}

resource "google_compute_health_check" "http-basic-check" {
  name = "http-basic-check"
  http_health_check {
    port = 9292
  }
}

resource "google_compute_backend_service" "web-backend-service" {
  name          = "backend-service"
  health_checks = [google_compute_health_check.http-basic-check.self_link]
  protocol      = "HTTP"
  port_name     = "puma"
  backend {
    group = google_compute_instance_group.lb.self_link
  }
}

resource "google_compute_url_map" "web-map-http" {
 name        = "web-map-http"
 default_service = google_compute_backend_service.web-backend-service.self_link
}

resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.web-map-http.self_link
}

resource "google_compute_global_forwarding_rule" "http-content-rule" {
  name = "http-content-rule"
  ip_address = google_compute_global_address.lb-ipv4.self_link
  target = google_compute_target_http_proxy.http-lb-proxy.self_link
  port_range = "80"
}
