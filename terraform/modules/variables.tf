# Networking

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR block"
  default     = "10.0.1.0/24"
}

variable "network_cidr" {
  type        = string
  description = "Network CIDR block"
  default     = "10.0.0.0/16"
}

variable "network_zone" {
  type        = string
  description = "Network zone"
  default     = "eu-central"
}

variable "environment" {
  type        = string
  description = "Environment (e.g., dev, test, prod)"
  default     = "dev"
}

variable "server_image" {
  type        = string
  description = "Server image"
  default     = "ubuntu-24.04"
}

variable "server_type" {
  type        = string
  description = "Hetzner Server type"
  default     = "cax11"
}

variable "server_location" {
  type        = string
  description = "Hetzner Server Location"
  default     = "fsn1"
}

variable "master_node_network_ip" {
  type        = string
  description = "Master Node Network IP"
  default     = "10.0.1.1"
}

variable "master_ssh_public_key" {
  type        = string
  description = "SSH Public Key"
}

variable "lb_type" {
  type        = string
  description = "Load Balancer Type"
  default     = "lb11"
}

variable "lb_location" {
  type        = string
  description = "Load Balancer Location"
  default     = "fsn1"
}

variable "worker_ssh_public_key" {
  type        = string
  description = "SSH Public Key"
}

variable "master_ssh_private_key" {
  type        = string
  description = "Master SSH Private Key"
}

variable "worker_ssh_private_key" {
  type        = string
  description = "Worker SSH Private Key"
}

variable "worker_count" {
  default = 2
  type = number
  description = "Number of worker nodes"
}