resource "hcloud_network" "private_network" {
  ip_range = var.network_cidr
  name     = "${var.environment}-k8s-cluster"
}

resource "hcloud_network_subnet" "private_network_subnet" {
  ip_range     = var.subnet_cidr
  network_id   = hcloud_network.private_network.id
  network_zone = var.network_zone
  type         = "cloud"
}

resource "hcloud_load_balancer" "load_balancer" {
  load_balancer_type = var.lb_type
  name               = "${var.environment}-k8s-lb"
  location           = var.lb_location
  delete_protection  = false

  depends_on = [hcloud_network_subnet.private_network_subnet, hcloud_server.master-node]
}

resource "hcloud_load_balancer_service" "load_balancer_service" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  protocol         = "http"

  depends_on = [hcloud_load_balancer.load_balancer]
}

resource "hcloud_load_balancer_network" "lb_network" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  network_id       = hcloud_network.private_network.id

  depends_on = [hcloud_network_subnet.private_network_subnet, hcloud_load_balancer.load_balancer]
}

resource "hcloud_load_balancer_target" "load_balancer_target_worker" {
  for_each         = { for idx, server in hcloud_server.workers-node : idx => server }
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  type             = "server"
  server_id        = each.value.id
  use_private_ip   = true

  depends_on = [
    hcloud_network_subnet.private_network_subnet, hcloud_load_balancer_network.lb_network, hcloud_server.workers-node
  ]
}
