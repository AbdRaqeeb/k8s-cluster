resource "hcloud_ssh_key" "worker_ssh_key" {
  name       = "${var.environment}-k8s-ssh-key"
  public_key = var.worker_ssh_public_key
}

resource "hcloud_server" "workers-node" {
  count = var.worker_count

  name        = "${var.environment}-worker-node-${count.index + 1}"
  image       = var.server_image
  server_type = var.server_type
  location    = var.server_location
  ssh_keys = [hcloud_ssh_key.worker_ssh_key.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.private_network.id
  }

  connection {
    host = self.ipv4_address
    user = "root"
    private_key = var.worker_ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /root/.ssh",
      "echo '${var.master_ssh_private_key}' > /root/.ssh/master.pem",
      "chmod 600 /root/.ssh/master.pem",
      "cat > /root/setup-worker.sh <<'EOL'",
      "#!/bin/bash",
      "set -e",
      "cat > /etc/modules-load.d/k8s.conf <<EOF",
      "overlay",
      "br_netfilter",
      "EOF",
      "modprobe overlay",
      "modprobe br_netfilter",
      "cat > /etc/sysctl.d/k8s.conf <<EOF",
      "net.bridge.bridge-nf-call-iptables = 1",
      "net.bridge.bridge-nf-call-ip6tables = 1",
      "net.ipv4.ip_forward = 1",
      "EOF",
      "sysctl --system",
      "apt-get update",
      "apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" > /etc/apt/sources.list.d/docker.list",
      "apt-get update",
      "apt-get install -y containerd.io",
      "mkdir -p /etc/containerd",
      "containerd config default > /etc/containerd/config.toml",
      "sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml",
      "systemctl restart containerd",
      "systemctl enable containerd",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' > /etc/apt/sources.list.d/kubernetes.list",
      "apt-get update",
      "apt-get install -y kubelet kubeadm kubectl",
      "apt-mark hold kubelet kubeadm kubectl",
      "$1",
      "EOL",
      "chmod +x /root/setup-worker.sh",
      "echo 'Waiting for master node to be ready...'",
      "until nc -z ${var.master_node_network_ip} 6443; do sleep 10; done",
      "JOIN_CMD=$(ssh -o StrictHostKeyChecking=no -i /root/.ssh/master.pem root@${var.master_node_network_ip} 'kubeadm token create --print-join-command')",
      "bash /root/setup-worker.sh \"$JOIN_CMD\""
    ]
  }

  depends_on = [hcloud_network_subnet.private_network_subnet, hcloud_server.master-node]
}
