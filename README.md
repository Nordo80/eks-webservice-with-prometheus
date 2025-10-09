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
    │   ├── iam.tf
    │   ├── instance-profile.tf
    │   ├── launch-template.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── sg.tf
    │   ├── variables.tf
    │   └── versions.tf
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

Before provisioning any infrastructure, a few critical components were **created manually** to ensure secure and stable operation of the environment:

- 🔐 **KMS Key ARN** — used for encryption of Terraform-managed resources and EKS-related data.  
  This guarantees that all sensitive data (like secrets, states, and stored configurations) remain securely encrypted.

- 🌐 **Elastic IPs** — reserved and attached to the EKS LoadBalancer.  
  This ensures that the web service running in EKS always uses **static IP addresses**, allowing stable integration with Prometheus and external monitoring tools.

These manual setup steps were essential for maintaining infrastructure consistency, especially when redeploying or scaling the environment.


### 1️⃣ Building and Pushing Docker Image

```bash
cd applications/web-service/image/
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com

docker build -t web-service .
docker tag web-service:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/web-service:latest
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/web-service:latest
```

### 2️⃣ Deploying Web Service via Terraform and Kustomize

- The **Terraform module** provisions EKS cluster and IAM resources.
- The **environment/test** folder applies specific configurations for testing.
- Once infrastructure is ready:

**Terraform**
```bash
cd application/web-service/environment/test
terraform init
terraform plan
terraform apply
```

**Kustomize**
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
terraform plan
terraform apply
```

Once deployed, Prometheus scrapes metrics from the EKS web-service via the public LoadBalancer IP.

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
### Web service
<img width="1081" height="304" alt="main_page" src="https://github.com/user-attachments/assets/8516a2a1-8a7f-419f-8cbe-9ad1b527327b" />
<img width="1774" height="336" alt="gandalf_page" src="https://github.com/user-attachments/assets/94cf10ed-b65e-4ab4-84e9-857f1d5137a0" />
<img width="1774" height="336" alt="colombo_page" src="https://github.com/user-attachments/assets/f455e0df-8ff3-45b2-983d-1aae6401d032" />
<img width="1081" height="304" alt="metrics_page" src="https://github.com/user-attachments/assets/94d5072f-55da-4e80-bac4-43ae70000944" />

### Prometheus
<img width="1774" height="336" alt="prometheus1" src="https://github.com/user-attachments/assets/712c59b8-aa5a-49bf-8a57-4a26c91f999c" />
<img width="1777" height="1045" alt="prometheus2" src="https://github.com/user-attachments/assets/1f961479-d6f7-4eb0-b21a-476e292fceb4" />

---

## 🧩 Future Improvements

- Add Grafana for visualization    
- Use Prometheus Operator inside EKS for production-grade monitoring
- Add logging for application
- Will make infra without public prometheus and /metric endpoint
- Prepare GitHub Actions pipeline
- And MANY other things

---

## 🧑‍💻 Author

**Made with ❤️ by [Nordo80](https://github.com/Nordo80)**

---
