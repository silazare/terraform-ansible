# Variables for main.tf
variable "project" {
  description = "Project ID"
}

variable "region" {
  description = "Region"
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone"
  default     = "europe-west1-b"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}

variable "remote_user" {
  description = "Remote user for provisioners"
}

variable "disk_image" {
  description = "Disk image"
  default     = "centos-cloud/centos-7"
}

variable "machine_type" {
  description = "Instance type"
  default     = "g1-small"
}

variable "node_count" {
  default = "3"
}

variable "source_ip" {
  default = "0.0.0.0/0"
}

