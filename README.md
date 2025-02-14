# Kubernetes Infrastructure Project

This repository contains Infrastructure as Code (IaC) and configuration for setting up a production-ready Kubernetes cluster on Hetzner Cloud, complete with monitoring, logging, and CI/CD pipelines.

## 🏗 Infrastructure Overview

- **Cloud Provider**: Hetzner Cloud
- **Infrastructure as Code**: Terraform
- **Container Orchestration**: Kubernetes (v1.31)
- **Ingress Controller**: NGINX
- **Monitoring**: Prometheus + Grafana
- **Logging**: Vector + Better Stack
- **CI/CD**: GitHub Actions

## 🚀 Quick Start

### Prerequisites

- Hetzner Cloud Account
- Terraform CLI (v1.10.5+)
- kubectl
- GitHub Account
- Domain Name (for Ingress configuration)
- Better Stack Account (for log ingestion) [BetterStack](www.betterstack.com)

### Environment Variables

Create the following secrets in your GitHub repository:

```bash
# Hetzner Cloud
HCLOUD_TOKEN=your_hetzner_token

# SSH Keys
MASTER_SSH_PRIVATE_KEY=your_master_private_key
WORKER_SSH_PRIVATE_KEY=your_worker_private_key
MASTER_SSH_PUBLIC_KEY=your_master_public_key
WORKER_SSH_PUBLIC_KEY=your_worker_public_key

# Terraform Cloud
TF_API_TOKEN=your_terraform_token

# Better Stack 

LIVE_TAIL_TOKEN=your_betterstack_token

# Container Registry
CR_PAT=your_github_cr_pat
```

### Directory Structure

```
.
├── .github/
│   └── workflows/           # GitHub Actions workflows
├── code/                    # Application code
├── kubernetes/
│   ├── apps/               # Application manifests
│   ├── logging/            # Logging configuration
│   ├── monitoring/         # Monitoring stack
│   └── nginx/              # NGINX Ingress configuration
└── terraform/
    ├── modules/            # Terraform modules
    └── env/                # Environment-specific configurations
        ├── dev/
        ├── staging/
        └── production/
```

## 🔧 Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/repo-name.git
cd repo-name
```

2. Initialize Terraform:
```bash
cd terraform/env/dev
terraform init
```

3. Apply Terraform configuration:
```bash
terraform plan
terraform apply
```

4. Configure kubectl:
```bash
# Get kubeconfig from master node
scp root@master-node-ip:/etc/kubernetes/admin.conf ~/.kube/config
```

5. Deploy core components:
```bash
# Deploy NGINX Ingress Controller
kubectl apply -f kubernetes/nginx/

# Deploy monitoring stack
kubectl apply -k kubernetes/monitoring/

# Deploy logging
kubectl apply -k kubernetes/logging/

# Deploy demo application
kubectl apply -k kubernetes/apps/demo-app/
```

## 🔍 Features

### Infrastructure

- Multi-node Kubernetes cluster
- Private networking
- Load balancer integration
- Automated node provisioning
- High availability setup

### Monitoring

- Prometheus metrics collection
- Grafana dashboards
- Node metrics via Node Exporter
- Custom application metrics

### Logging

- Centralized logging with Vector
- Log forwarding to Better Stack
- Kubernetes events logging
- Application logs collection

### CI/CD

- Automated infrastructure deployment
- Container image building and pushing
- Kubernetes deployments
- Environment-specific configurations

## 🛠 Development

### Adding New Applications

1. Create Kubernetes manifests in `kubernetes/apps/your-app/`
2. Create GitHub Actions workflow in `.github/workflows/`
3. Configure Ingress in your application manifests
4. Deploy using:
```bash
kubectl apply -k kubernetes/apps/your-app/
```

### Modifying Infrastructure

1. Update Terraform configurations in `terraform/modules/` or environment-specific directories
2. Create a pull request
3. GitHub Actions will run Terraform plan
4. Review and merge to apply changes

## 📊 Monitoring

Access monitoring dashboards:

- Grafana: https://grafana.yourdomain.com
- Prometheus: https://prometheus.yourdomain.com

## 🔒 Security

- Private network configuration
- RBAC implementation
- Network policies
- Secret management via GitHub Secrets
- TLS configuration for Ingress

## ⚙️ Configuration Reference

### Infrastructure Variables

See `terraform/*/variables.tf` for available configuration options.

### Kubernetes Resources

- CPU and memory requests/limits
- Node selector configurations
- Affinity rules
- Taints and tolerations

## ✅ Verification Steps

After deployment, verify the setup:

1. Check node status:
```bash
kubectl get nodes
```

2. Verify monitoring:
```bash
kubectl -n monitoring get pods
```

3. Check logging:
```bash
kubectl -n vector get pods
```

4. Test application access:
```bash
curl https://demo.yourdomain.com
```