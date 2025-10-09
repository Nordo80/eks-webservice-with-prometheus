# 🚀 eks-webservice-with-prometheus

![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Orchestration-EKS-326CE5?logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&logoColor=white)
![Flask](https://img.shields.io/badge/Backend-Flask-000000?logo=flask&logoColor=white)
![Prometheus](https://img.shields.io/badge/Monitoring-Prometheus-E6522C?logo=prometheus&logoColor=white)

---

## 🧭 Introduction

**eks-webservice-with-prometheus** is a full-stack infrastructure project showcasing how to deploy a **Flask web application** on **AWS EKS**, monitored by **Prometheus** running on an **EC2 instance**.  
The goal was to automate the infrastructure setup using **Terraform** and **Kustomize**, containerize the application using **Docker**, and establish monitoring through Prometheus scraping metrics from the web service.

🧠 *No AI tools were used during implementation — only official documentation, local repositories, and manual configurations. This README was generated using AI purely for presentation purposes.*

---

## 🧱 Tech Stack

| Layer | Technology | Purpose |
|-------|-------------|----------|
| Cloud | **AWS** | Infrastructure hosting |
| IaC | **Terraform** | Automated provisioning of EKS & EC2 resources |
| Container | **Docker** | Web app containerization |
| Orchestration | **EKS (Kubernetes)** | Hosting web-service pods |
| Backend | **Flask (Python)** | Lightweight web framework |
| Monitoring | **Prometheus (on EC2)** | Metrics collection from EKS web-service |
| Config Mgmt | **Kustomize** | Declarative Kubernetes manifests |

---

## 🗂 Repository Structure

```
.
├── applications
│   ├── prometheus
│   │   └── environment
│   │       └── test
│   │           ├── prometheus.tf
│   │           ├── prometheus.tmpl
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
│       │   └── templates/
│       └── kustomize
│           ├── kustomization.yml
│           └── resources/
│               ├── deployment.yaml
│               └── service.yaml
└── terraform_modules
    ├── prometheus
    └── web-service
```

---

## 🏗 Architecture Overview

### 🧩 High-Level Design

```
                      ┌────────────────────────────┐
                      │        AWS Cloud           │
                      │                            │
                      │    ┌──────────────────┐     │
                      │    │   EC2 Instance   │     │
                      │    │ (Prometheus)     │◄────┼─── Scrapes metrics
                      │    └──────────────────┘     │
                      │              ▲              │
                      │              │              │
                      │    ┌──────────────────┐     │
                      │    │   AWS EKS        │     │
                      │    │ (Web Service)    │     │
                      │    │   Flask App      │     │
                      │    └──────────────────┘     │
                      └────────────────────────────┘
```

Prometheus runs on a **dedicated EC2 instance**, pulling metrics via the `/metrics` endpoint from the Flask web-service deployed inside EKS.  
This separation allows for clear observability and independent scaling of monitoring and application layers.

---

## 🚀 Deployment Process

### 1️⃣ Building and Pushing Docker Image

```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com

docker build -t web-service .
docker tag web-service:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/web-service:latest
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/web-service:latest
```

### 2️⃣ Deploying Web Service via Terraform and Kustomize

- The **Terraform module** provisions EKS cluster and IAM resources.
- The **environment/test** folder applies specific configurations for testing.
- Once infrastructure is ready:

```bash
aws eks update-kubeconfig --region <region> --name web-service
kubectl create namespace web-service-deployment
kubectl apply -k ./applications/web-service/kustomize/
```

The web-service exposes three endpoints:
- `/metrics` → Prometheus metrics  
- `/colombo` → Current time in Colombo  
- `/gandalf` → Displays Gandalf GIF  

### 3️⃣ Deploying Prometheus on EC2

Prometheus was provisioned using a dedicated Terraform module (`terraform_modules/prometheus`).  
A simple template (`prometheus.tmpl`) defines job targets, including the EKS service endpoint.

```bash
cd applications/prometheus/environment/test
terraform init
terraform apply -auto-approve
```

Once deployed, Prometheus scrapes metrics from the EKS web-service via the public LoadBalancer IP.

---

## 🌐 Network & Access Setup

- **Prometheus EC2** accesses the **EKS LoadBalancer** using the external IP exposed by the `Service` manifest.  
- Security Groups were configured to allow Prometheus inbound/outbound access on port `9090` and application metrics on `80`.  
- Elastic IPs were assigned for easier monitoring and persistence.

---

## 📊 Prometheus Integration

Prometheus configuration (`prometheus.tmpl`) defines the web-service target:

```yaml
scrape_configs:
  - job_name: 'web-site'
    scrape_interval: 2m
    scrape_timeout: 30s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets: ['<web-service-ip>']
```

Metrics can be visualized by visiting:

```
http://<prometheus-ec2-public-ip>:9090
```

---

## ⚡ Troubleshooting

| Issue | Solution |
|-------|-----------|
| Prometheus not scraping | Check `targets` tab in Prometheus UI |
| Metrics endpoint timeout | Ensure `Service` exposes correct port and type `LoadBalancer` |
| Terraform errors | Run `terraform validate` and check provider credentials |

---

## 🖼 Screenshots

> Screenshots will be added here, showing successful deployment and Prometheus metrics scraping.

---

## 🧩 Future Improvements

- Add Grafana for visualization    
- Use Prometheus Operator inside EKS for production-grade monitoring
- Add logging for application
- Will make infra without public prometheus and /metric endpoint
- And MANY other things

---

## 🧑‍💻 Author

**Made with ❤️ by [Nordo80](https://github.com/Nordo80)**

---
