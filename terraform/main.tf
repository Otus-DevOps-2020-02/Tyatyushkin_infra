provider "google" {
  # Версия провайдера
  version = "2.15"
  # ID проекта
  project = var.project
  region = var.region
}
