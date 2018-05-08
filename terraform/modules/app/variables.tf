variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable private_key_path {
  description = "Path to the private key used to connect to instance"
}

variable zone {
  description = "Zone"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable db_internal_ip {
  description = "DB internal network ip"
}

variable deployment_trigger {
  description = "Turn on/off app deployment to app instance"
  default     = "false"
}
