terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Varteqar"

    workspaces {
      name = "production"
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.49.1"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

module "k8s_cluster" {
  source = "../../modules"

  master_ssh_public_key  = var.master_ssh_public_key
  worker_ssh_public_key  = var.worker_ssh_public_key
  environment            = var.environment
  network_cidr           = var.network_cidr
  subnet_cidr            = var.subnet_cidr
  network_zone           = var.network_zone
  server_image           = var.server_image
  server_type            = var.server_type
  server_location        = var.server_location
  master_node_network_ip = var.master_node_network_ip
  lb_type                = var.lb_type
  lb_location            = var.lb_location
  master_ssh_private_key = var.master_ssh_private_key
  worker_ssh_private_key = var.worker_ssh_private_key
  worker_count           = var.worker_count
}