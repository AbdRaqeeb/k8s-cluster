resource "hcloud_ssh_key" "master_ssh_key" {
  name       = "${var.environment}-ssh-key-01"
  public_key = var.master_ssh_public_key
}

resource "hcloud_server" "master-node" {
  name        = "${var.environment}-master-node"
  image       = var.server_image
  server_type = var.server_type
  location    = var.server_location
  ssh_keys = [hcloud_ssh_key.master_ssh_key.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.private_network.id
    ip         = var.master_node_network_ip
  }

  connection {
    host = self.ipv4_address
    user = "root"
    private_key = var.master_ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "cat > /root/setup-master.sh <<'EOL'",
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
      "kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${var.master_node_network_ip}",
      "mkdir -p $HOME/.kube",
      "cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "chown $(id -u):$(id -g) $HOME/.kube/config",
      "kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml",
      "EOL",
      "chmod +x /root/setup-master.sh",
      "/root/setup-master.sh"
    ]
  }

  depends_on = [hcloud_network_subnet.private_network_subnet]
}