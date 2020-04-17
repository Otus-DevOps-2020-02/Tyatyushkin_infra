terraform {
  backend "gcs" {
    bucket  = "tyatyushkin-tf"
    prefix  = "prod"
  }
}
