variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}

variable private_key_path {
  description = "Private key path"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable insta_count {
  description = "count of instances"
  default     = 1
}
