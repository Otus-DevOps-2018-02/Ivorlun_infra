variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west4"
}

variable app_zone {
  description = "Zone"
  default     = "europe-west4-b"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable num_of_apps {
  description = "number of instances"
  default     = 2
}
