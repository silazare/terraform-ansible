# Variables for main.tf
variable "do_token" {
  description = "Digital Ocean API Token"
}

variable "public_key" {
  description = "Digital Ocean Public Key"
}

variable "private_key" {
  description = "Digital Ocean Private Key"
}

variable "ssh_fingerprint" {
  description = "Digital Ocean SSH fingerprint"
}

variable "region" {
  description = "Digital Ocean Region"
}

variable "image" {
  description = "Droplet Image"
  default     = "centos-7-x64"
}

variable "size" {
  description = "Droplet size"
  default     = "s-1vcpu-1gb"
}

variable "source_range" {
  description = "Digital Ocean firewall source range or IP"
  default     = "0.0.0.0/0"
}

