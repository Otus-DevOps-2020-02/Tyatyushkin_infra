terraform {
  # Версия terraform
  required_version = "~> 0.12.19"
}

provider "google" {
  # Версия провайдера
  version = "2.15"
  # ID проекта
  project = var.project
  region = var.region
}
