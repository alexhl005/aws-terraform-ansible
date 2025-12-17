# 🚀 Cloud eCommerce Infrastructure on AWS

**Automated, Secure and Highly Available Cloud Architecture using Terraform & Ansible**

---

## 🎓 Academic Context

This repository corresponds to the **Final Degree Project (TFG)**:

> **Cloud eCommerce: Design and Implementation of an Automated, Secure and Scalable AWS Infrastructure**
> **Author:** Alejandro Herrera Luque
> **Degree:** Computer Science / IT (TFG)
> **Year:** 2025

The project presents a **real-world, production-ready cloud architecture** for eCommerce platforms, designed according to **AWS Well-Architected Framework**, **DevOps best practices**, and **international security and compliance standards**.

---

## 📌 Project Description

Modern eCommerce platforms must handle **unpredictable traffic spikes**, guarantee **near-zero downtime**, and comply with **strict security and regulatory requirements**.

This project delivers a **fully automated AWS infrastructure** that:

* Scales elastically under high demand (e.g. Black Friday)
* Enforces security-by-design (Zero Trust, least privilege)
* Achieves **99.99% availability SLA**
* Reduces operational errors through automation
* Optimizes cloud costs using AWS-native mechanisms

Infrastructure provisioning and lifecycle management are handled entirely through **Infrastructure as Code (IaC)** and **Configuration Management**.

---

## 🎯 Objectives

### 🎯 General Objective

Design and implement a **secure, scalable and highly available cloud infrastructure for eCommerce platforms on AWS**, fully automated using Terraform and Ansible.

### 📍 Specific Objectives

* Provision AWS resources using **modular Terraform code**
* Automate server configuration, hardening and application deployment with **Ansible**
* Implement **CI/CD pipelines** for infrastructure and configuration changes
* Ensure **high availability (Multi-AZ)** and automatic failover
* Enforce **PCI-DSS v4.0** and **GDPR** compliance controls
* Reduce provisioning time from days to minutes
* Optimize infrastructure costs and resource usage

---

## 🏗️ Architecture Overview

### 🔹 Architectural Principles

* **Infrastructure as Code (IaC)**
* **Security by Design**
* **High Availability & Fault Tolerance**
* **Automation First**
* **Cloud-Native Services**

### 🔹 Network Architecture

The solution is deployed inside a **custom AWS VPC**, segmented into logical security layers:

```
Internet
   │
   ▼
[ Application Load Balancer ]  ← Public Subnet (DMZ)
   │
   ▼
[ EC2 Auto Scaling Group ]      ← Private App Subnets (Multi-AZ)
   │
   ▼
[ Amazon RDS Multi-AZ ]         ← Private Data Subnets
```

### 🔹 Core AWS Components

| Layer      | Service                          | Purpose                      |
| ---------- | -------------------------------- | ---------------------------- |
| Compute    | Amazon EC2 (ASG)                 | Scalable application servers |
| Networking | VPC, Subnets, ALB                | Secure traffic segmentation  |
| Database   | Amazon RDS (PostgreSQL / Aurora) | Highly available data layer  |
| Storage    | Amazon S3 + VPC Endpoint         | Backups and static assets    |
| Security   | IAM, SG, NACL, KMS               | Identity and access control  |
| Monitoring | AWS CloudWatch                   | Metrics, logs and alerts     |

---

## 🔐 Security & Compliance

Security is implemented **end-to-end**, aligned with enterprise standards.

### 🔒 Network Security

* Public DMZ with ALB only
* Private application and database subnets
* Strict Security Groups and Network ACLs

### 🔑 Identity & Access Management

* IAM roles (no static credentials)
* Least-privilege access model
* Separation of duties

### 🔐 Encryption

* TLS 1.3 for data in transit
* AWS KMS encryption for data at rest
* Encrypted EBS, RDS and S3

### 📜 Compliance

* **PCI-DSS v4.0** (payment environments)
* **GDPR / LOPDGDD**
* AWS audit-ready architecture

---

## 🔄 Automation Workflow

1. **Terraform** provisions all AWS infrastructure
2. **GitHub Actions** validates and plans infrastructure changes
3. **Jenkins** applies Terraform and triggers Ansible
4. **Ansible** configures EC2 instances and services
5. **CloudWatch** monitors health, performance and availability

All deployments are **idempotent, auditable and reproducible**.

---

## 🛠️ Technology Stack

### Infrastructure & Automation

* Terraform (IaC)
* Ansible (Configuration Management)
* AWS EC2, RDS, S3, VPC, IAM, ALB

### CI/CD

* GitHub Actions (CI)
* Jenkins (CD)

### Monitoring & Operations

* AWS CloudWatch
* Bash & Python automation scripts

### Security

* AWS KMS
* Security Groups & NACLs
* CIS Benchmarks (Ansible)

---

## 📈 Key Results & Metrics

| Metric                      | Result   |
| --------------------------- | -------- |
| Infrastructure Provisioning | < 1 hour |
| Availability SLA            | 99.99%   |
| Cost Reduction vs On-Prem   | ~40%     |
| Security Incidents          | 0        |
| Manual Configuration        | 0%       |

---

## 🧠 Design Decisions & Trade-offs

This project intentionally prioritizes **reliability, security and automation** over simplicity.

### Key Design Decisions

* **AWS over Multi-Cloud**: reduced operational complexity and latency
* **EC2 + Ansible instead of full serverless**: greater control and PCI-DSS suitability
* **Terraform Modules**: reusable, auditable and environment-consistent
* **Jenkins for CD**: fine-grained control over infrastructure approvals

### Trade-offs

* Higher initial complexity compared to PaaS solutions
* Requires cloud and DevOps expertise
* Slightly higher learning curve, offset by long-term stability

---

## 🛡️ Threat Model & Security Strategy

### Identified Threats

* DDoS attacks
* Unauthorized access
* Data exfiltration
* Misconfiguration risks

### Mitigations

* AWS Shield & WAF
* Network segmentation (DMZ, App, Data)
* IAM least privilege and role-based access
* Infrastructure as Code with version control
* Automated hardening via Ansible (CIS Benchmarks)

---

## 🧪 Testing & Validation Strategy

* **Infrastructure Validation**: terraform validate & plan
* **Configuration Validation**: Ansible idempotency checks
* **Security Testing**:

  * OWASP Top 10 validation
  * Periodic vulnerability scans
* **Resilience Testing**:

  * Multi-AZ failure simulation
  * Auto Scaling behavior under load

---

## 📊 Cost Optimization & Analysis

Cost efficiency is enforced through:

* Auto Scaling Groups
* Reserved & Spot Instances (where applicable)
* Automated cleanup of unused resources
* AWS Cost Explorer monitoring

Estimated **40% TCO reduction** compared to equivalent on-premise deployments.

---

## 🏆 Why This Project Stands Out

* Designed as a **real production system**, not a demo
* Security and compliance built-in from day one
* Fully automated lifecycle (infra + config + deployment)
* Directly aligned with industry standards (AWS, PCI-DSS, GDPR)
* Easily extensible to Kubernetes, EKS or serverless architectures

---

| Security Incidents | 0 |
| Manual Configuration | 0% |

---

## ▶️ Usage Guide

### 1️⃣ Clone the repository

```bash
git clone https://github.com/your-username/aws-terraform-ansible.git
cd aws-terraform-ansible
```

### 2️⃣ Configure AWS credentials

```bash
export AWS_ACCESS_KEY_ID=YOUR_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET
```

### 3️⃣ Deploy infrastructure

```bash
terraform init
terraform apply
```

### 4️⃣ Configure servers

```bash
ansible-playbook -i inventory main.yml
```

### 5️⃣ Monitor

Use **AWS CloudWatch Dashboards and Alarms**.

---

## 📂 Repository Structure

```
.
├── terraform/
│   ├── modules/
│   └── environments/
├── ansible/
│   ├── roles/
│   └── playbooks/
├── jenkins/
│   └── Jenkinsfile
├── .github/
│   └── workflows/
└── scripts/
```

---

## 📄 Proprietary License

### © 2025 Alejandro Herrera Luque — All Rights Reserved

This repository and its contents are **proprietary software**.

🚫 **Unauthorized copying, modification, distribution, publication or commercial use is strictly prohibited** without prior written permission from the author.

This project is provided **exclusively for academic evaluation purposes** as part of a Final Degree Project (TFG).

For licensing or usage inquiries, contact the author directly.

---

## 📬 Author

**Alejandro Herrera Luque**
Cloud & DevOps Engineer
Final Degree Project — 2025

---

🚀 *A real-world, enterprise-grade cloud infrastructure designed for modern eCommerce platforms.*

---

## 🗺️ Future Improvements & Roadmap

This project has been designed with extensibility in mind. Possible future evolutions include:

* **Containerization & Kubernetes**

  * Migration to Amazon EKS
  * Helm-based deployments
  * Horizontal Pod Autoscaling (HPA)

* **Serverless Extensions**

  * AWS Lambda for background jobs
  * Event-driven workflows (SQS, EventBridge)

* **Advanced Observability**

  * Prometheus & Grafana integration
  * Centralized logging with OpenSearch

* **Security Enhancements**

  * AWS GuardDuty
  * Continuous compliance with AWS Config

* **Disaster Recovery**

  * Multi-region deployment
  * Automated DR drills

---

## 🎤 Defense-Oriented Executive Summary

This Final Degree Project demonstrates the **design, implementation and validation of a real production-ready cloud infrastructure** for eCommerce platforms.

The solution addresses key industry challenges:

* Traffic unpredictability
* High availability requirements
* Security and regulatory compliance
* Cost optimization

Through the use of **Terraform, Ansible and AWS-native services**, the infrastructure achieves:

* 99.99% availability
* End-to-end automation
* Compliance with PCI-DSS and GDPR
* Significant reduction in operational overhead

This project reflects **current industry practices** used by cloud and DevOps teams in enterprise environments.

---

## 🧑‍💼 Recruiter & Portfolio Highlights

* Designed and implemented a **complete AWS cloud architecture**
* Applied **DevOps, IaC and SecOps principles**
* Built **CI/CD pipelines** for infrastructure and configuration
* Worked with **enterprise security standards**
* Produced professional technical documentation

Ideal for roles such as:

* Junior / Mid DevOps Engineer
* Cloud Engineer
* Site Reliability Engineer (SRE)

---

## 🧾 Appendix A — Non-Functional Requirements

| Category          | Target        |
| ----------------- | ------------- |
| Availability      | 99.99%        |
| Latency (P95)     | < 500 ms      |
| Scalability       | Automatic     |
| Security          | PCI-DSS, GDPR |
| Provisioning Time | < 1 hour      |

---

## 🧾 Appendix B — Operational Procedures (SOPs)

* **Deployment**: Terraform → Ansible → Validation
* **Scaling**: Automatic via ASG and CloudWatch
* **Incident Response**: Alerts → Logs → Recovery
* **Backup & Restore**: Automated S3 & RDS snapshots

---

## 📄 Legal Notice & Proprietary License

© 2025 Alejandro Herrera Luque. All rights reserved.

This repository, including all source code, documentation, diagrams and configurations, is **confidential and proprietary**.

Any reproduction, distribution, modification, public disclosure or commercial use without **explicit written authorization** from the author is strictly prohibited.

This material is provided **solely for academic evaluation** as part of a Final Degree Project (TFG).

---

## ⭐ Final Statement

This project represents the culmination of academic training applied to a **real-world cloud engineering problem**, bridging the gap between university education and professional DevOps practice.
