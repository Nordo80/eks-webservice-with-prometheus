# 🚀 eks-webservice-with-prometheus

![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Orchestration-EKS-326CE5?logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&logoColor=white)
![Flask](https://img.shields.io/badge/Backend-Flask-000000?logo=flask&logoColor=white)
![Prometheus](https://img.shields.io/badge/Monitoring-Prometheus-E6522C?logo=prometheus&logoColor=white)
![Ansible](https://img.shields.io/badge/Automation-Ansible-EE0000?logo=ansible&logoColor=white)

---

## 🧭 Introduction

**eks-webservice-with-prometheus** is a complete infrastructure project demonstrating how to deploy a **Flask web application** on **AWS EKS**, monitored by **Prometheus** running on an **EC2 instance**.  
The infrastructure is automated with **Terraform**, Kubernetes configuration is managed via **Kustomize**, and **Prometheus** installation is automated with **Ansible**.

🧠 *No AI tools were used during implementation — only official documentation, local repositories, and manual configuration. This README was generated with AI purely for presentation purposes.*

---

## 🧱 Tech Stack

| Layer | Technology | Purpose |
|-------|-------------|----------|
| Cloud | **AWS** | Infrastructure hosting |
| IaC | **Terraform** | Automated provisioning of EKS & EC2 resources |
| Configuration Mgmt | **Ansible** | Automated Prometheus installation on EC2 |
| Container | **Docker** | Web app containerization |
| Orchestration | **EKS (Kubernetes)** | Hosting web-service pods |
| Backend | **Flask (Python)** | Lightweight web framework |
| Monitoring | **Prometheus (on EC2)** | Metrics collection from EKS web-service |
| Manifests | **Kustomize** | Declarative Kubernetes manifests |

---

## 🗂 Repository Structure

```
.
├── applications
│   ├── prometheus
│   │   ├── ansible
│   │   │   ├── ansible.cfg
│   │   │   ├── group_vars
│   │   │   │   ├── all
│   │   │   │   └── test
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── install.yml
│   │   │   ├── inventory
│   │   │   │   └── test
│   │   │   ├── meta
│   │   │   │   └── main.yml
│   │   │   └── roles
│   │   │       └── prometheus
│   │   │           ├── defaults
│   │   │           │   └── all
│   │   │           ├── handlers
│   │   │           │   └── main.yml
│   │   │           ├── meta
│   │   │           │   └── main.yml
│   │   │           ├── tasks
│   │   │           │   └── main.yml
│   │   │           └── templates
│   │   │               ├── prometheus.rules.yml.j2
│   │   │               ├── prometheus.service.j2
│   │   │               └── prometheus.yml.j2
│   │   └── environment
│   │       └── test
│   │           ├── prometheus.tf
│   │           └── provider.tf
│   └── web-service
│       ├── environment
│       │   └── test
│       │       ├── provider.tf
│       │       └── web-service.tf
│       ├── image
│       │   ├── app.py
│       │   ├── Dockerfile
│       │   ├── requirements.txt
│       │   ├── static
│       │   │   └── people_photo
│       │   │       └── gandalf-laughing.gif
│       │   └── templates
│       │       ├── gandalf_index.html
│       │       └── metrics_index.html
│       └── kustomize
│           ├── kustomization.yml
│           └── resources
│               ├── deployment.yaml
│               └── service.yaml
├── README.md
└── terraform_modules
    ├── prometheus
    │   ├── iam.tf
    │   ├── instance-profile.tf
    │   ├── launch-template.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── sg.tf
    │   ├── variables.tf
    │   └── versions.tf
    └── web-service
        ├── data.tf
        ├── iam.tf
        ├── locals.tf
        ├── main.tf
        ├── node-template.tf
        ├── outputs.tf
        ├── variables.tf
        └── versions.tf
```
---

## 🏗 Architecture Overview

### 🧩 High-Level Design

```
                      ┌────────────────────────────┐
                      │        AWS Cloud           │
                      │                            │
                      │    ┌──────────────────┐    │
                      │    │   EC2 Instance   │    │
                      │    │ (Prometheus)     │◄───┼─── Scrapes metrics
                      │    └──────────────────┘    │
                      │              ▲             │
                      │              │             │
                      │    ┌──────────────────┐    │
                      │    │   AWS EKS        │    │
                      │    │ (Web Service)    │    │
                      │    │   Flask App      │    │
                      │    └──────────────────┘    │
                      └────────────────────────────┘
```

Prometheus runs on a **dedicated EC2 instance**, pulling metrics via the `/metrics` endpoint from the Flask web-service deployed inside EKS.  
This separation allows for clear observability and independent scaling of monitoring and application layers.

---

## 🚀 Deployment Process

### 0️⃣ Pre-deployment Setup

Before deploying the infrastructure, several essential components were prepared manually:

- 🔐 **Created SSH key** — generated and placed in the `ssh/` directory.  
  Used by Ansible to connect to the EC2 instance for Prometheus installation.  

- ⚙️ **Installed Ansible Core** — required for automating Prometheus installation via `ansible-playbook`.

- 🔐 **KMS Key ARN** — used for encryption of Terraform-managed resources and EKS data.  

- 🌐 **Elastic IPs** — reserved and attached to the EKS LoadBalancer to provide a static IP address for consistent Prometheus monitoring.

---

### 1️⃣ Building and Pushing Docker Image

```bash
cd applications/web-service/image/
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com

docker build -t web-service .
docker tag web-service:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/web-service:latest
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/web-service:latest
```

---

### 2️⃣ Deploying Web Service via Terraform and Kustomize

```bash
cd applications/web-service/environment/test
terraform init
terraform apply
```

Then:

```bash
aws eks update-kubeconfig --region <region> --name web-service
kubectl create namespace web-service-deployment
kubectl apply -k ./applications/web-service/kustomize/
```

The web service exposes three endpoints:
- `/metrics` → Prometheus metrics  
- `/colombo` → current time in Colombo  
- `/gandalf` → displays Gandalf GIF  

---

### 3️⃣ Deploying Prometheus via Terraform and Ansible

1. **Provision EC2 instance** for Prometheus:
```bash
cd applications/prometheus/environment/test
terraform init
terraform apply
```

2. **Install Prometheus using Ansible:**
```bash
cd applications/prometheus/ansible
ansible-playbook -i inventory/test install.yml
```

Ansible installs and configures Prometheus on the EC2 instance using templates:
- `prometheus.yml.j2` — scrape target configuration  
- `prometheus.rules.yml.j2` — alert rules  
- `prometheus.service.j2` — systemd service configuration  

Once completed, Prometheus is available at:
```
http://<prometheus-ec2-public-ip>:9090
```

---

## 📊 Prometheus Integration

Example configuration from `prometheus.yml.j2`:

```yaml
global:
  scrape_interval: 2m

scrape_configs:
  - job_name: 'web-site'
    scrape_interval: 2m
    scrape_timeout: 30s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets: ['<web-service-lb-ip>']
```

---

## ⚡ Troubleshooting

| Issue | Solution |
|-------|-----------|
| Prometheus not scraping | Check `targets` tab in Prometheus UI |
| Timeout on /metrics | Ensure `Service` uses `LoadBalancer` and the correct port |
| Terraform errors | Run `terraform validate` and verify AWS credentials |
| Ansible SSH errors | Ensure SSH key exists in `ssh/` and `inventory/test` is configured correctly |

---

## 🖼 Screenshots
### Web service
<img width="1081" height="304" alt="main_page" src="https://github.com/user-attachments/assets/8516a2a1-8a7f-419f-8cbe-9ad1b527327b" />
<img width="1774" height="336" alt="gandalf_page" src="https://github.com/user-attachments/assets/94cf10ed-b65e-4ab4-84e9-857f1d5137a0" />
<img width="1774" height="336" alt="colombo_page" src="https://github.com/user-attachments/assets/f455e0df-8ff3-45b2-983d-1aae6401d032" />
<img width="1081" height="304" alt="metrics_page" src="https://github.com/user-attachments/assets/94d5072f-55da-4e80-bac4-43ae70000944" />

### Prometheus
<img width="1776" height="305" alt="prometheus1" src="https://github.com/user-attachments/assets/405fdf95-5b48-4a76-9a33-82b764909aad" />
<img width="1719" height="1010" alt="prometheus2" src="https://github.com/user-attachments/assets/ff3b8c1f-db2f-4d7f-83b9-5179ab183d6e" />

---

## 🧩 Future Improvements

- Add **Grafana** for visualization  
- Deploy Prometheus inside EKS using Prometheus Operator  
- Add application logging  
- Secure `/metrics` endpoint and Prometheus access  
- Add GitHub Actions CI/CD pipeline  
- Implement alerting and dashboards
- Add terraform state file into S3 bucket
- Seperated role and playbook for prometheus
- Add bastion host for managing other instances with ansible

---

## 🧑‍💻 Author

**Made with ❤️ by [Nordo80](https://github.com/Nordo80)**
