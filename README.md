# 🚀 AWS Infrastructure Automation with Terraform & Ansible

## 📌 Project Overview
This project aims to automate cloud infrastructure deployment in AWS using **Terraform** and **Ansible**. The automation includes provisioning EC2 instances, setting up VPCs, databases, monitoring, and implementing security best practices. 

## 🎯 Objectives
### General Objective:
- Design and implement an automated infrastructure in AWS using Terraform and Ansible.

### Specific Objectives:
- Deploy AWS infrastructure components such as **EC2 instances, VPCs, and RDS databases** using **Terraform**.
- Automate server configurations with **Ansible**, ensuring proper software installation and security settings.
- Implement **CI/CD pipelines** using AWS CodePipeline or Jenkins for automated application deployment.
- Configure **monitoring and logging** with AWS CloudWatch for performance analysis and early issue detection.
- Establish security measures with **IAM roles, backup solutions, and data encryption**.

## 🏗️ Architecture & Components
### 🔹 Infrastructure Components
- **Amazon EC2** - Auto Scaling web servers (Apache/Nginx) for backend services (Node.js/Django).
- **Amazon S3** - Secure storage for backups and static files.
- **Amazon RDS** - Multi-AZ database (MySQL/PostgreSQL) with restricted access.
- **VPC & Subnets** - Secure network segmentation with **Public, Private, and DMZ subnets**.
- **Elastic Load Balancer (ELB)** - Distributes incoming traffic and ensures high availability.
- **AWS CloudWatch** - Monitoring, logging, and alerting for real-time analysis.

### 🔹 Security Measures
- **IAM roles & policies** for access control.
- **Security Groups** and **Network ACLs** for restricted inbound/outbound traffic.
- **Encrypted backups and data storage** in S3 and RDS.

## 🔄 Automation Workflow
1. **Terraform** provisions AWS resources (**EC2, VPC, RDS, ELB, S3**).
2. **Ansible** configures servers with required software, security settings, and optimizations.
3. **CI/CD pipeline** (AWS CodePipeline/Jenkins) automates application deployment.
4. **CloudWatch** monitors performance, logs errors, and sends alerts.

## 🛠️ Tools & Technologies
- **Terraform** - Infrastructure as Code (IaC) for AWS resource management.
- **Ansible** - Configuration management and automation.
- **AWS EC2** - Scalable computing instances.
- **AWS RDS** - Managed relational databases.
- **AWS S3** - Storage for backups and static content.
- **AWS IAM** - Access control and permissions management.
- **AWS CloudWatch** - Monitoring and alerting.
- **AWS CodePipeline / Jenkins** - Continuous Integration/Deployment (CI/CD).
- **GitHub/GitLab** - Version control and collaboration.
- **Bash/Python** - Custom automation scripts.

## 🔍 Detailed Explanation of Components
### **Amazon EC2 – Application Servers**
- EC2 instances deployed in **Auto Scaling Groups** to handle varying traffic loads.
- Located in multiple **Availability Zones (AZs)** within a **Virtual Private Cloud (VPC)** for redundancy.
- Runs a **web server (Apache/Nginx)** and **backend applications (Node.js/Django)**.

### **Amazon S3 – Backup Storage**
- Stores **daily backups of databases** and static files.
- Implements **versioning and encryption (KMS)** for enhanced security.
- Uses **lifecycle policies** to automatically delete old backups.

### **Amazon RDS – Database & Authentication**
- Multi-AZ deployment for **high availability**.
- **Access restricted** using **Security Groups**, ensuring only EC2 instances in the same VPC can connect.
- Supports **MySQL/PostgreSQL** as the database engine.

### **VPC & Subnets – Network Security**
- **Custom VPC**: Defines IP ranges and networking rules.
- **Subnets**:
  - **PublicSubnet** (10.0.1.0/24) – Hosts **ELB and public-facing services**.
  - **PrivateSubnet** (10.0.2.0/24) – Hosts **EC2 instances and backend applications**.
  - **DMZSubnet** (10.0.3.0/24) – Isolated environment for added security.

### **Security Groups & Network ACLs**
- **Security Groups** control **allowed incoming/outgoing traffic**:
  - **ELB_SG**: Allows HTTP (80/tcp) and HTTPS (443/tcp) from anywhere.
  - **EC2_SG**: Allows SSH (22/tcp) and HTTP (80/tcp) only from ELB.
  - **RDS_SG**: Allows MySQL/PostgreSQL (3306/tcp) connections only from EC2 instances.
- **Network ACLs** ensure additional security by filtering network traffic.

### **Elastic Load Balancer (ELB) – Traffic Distribution**
- Uses **Application Load Balancer (ALB)** to distribute incoming requests.
- Manages **persistent sessions** and routes requests efficiently.
- Performs **health checks** to remove unhealthy instances.

### **CloudWatch – Monitoring & Alerts**
- Collects **metrics and logs** from EC2, RDS, and ELB.
- **Triggers alerts** based on traffic spikes or failures.
- **Automatically scales** EC2 instances based on demand.

## 📅 Project Timeline
- **Weeks 1-2**: Project design & architecture planning.
- **Weeks 3-5**: Infrastructure deployment with Terraform.
- **Weeks 6-7**: Server automation with Ansible.
- **Weeks 8-9**: Security, monitoring, and CI/CD integration.
- **Week 10**: Testing & documentation.

## 📈 Benefits
✅ **High Availability** - Multi-AZ architecture.
✅ **Security** - IAM roles, ACLs, encryption.
✅ **Scalability** - Auto Scaling and ELB.
✅ **Automation** - Terraform & Ansible reduce manual effort.
✅ **Monitoring** - CloudWatch ensures performance tracking.

## 📝 How to Use
1. Clone this repository:
   ```sh
   git clone https://github.com/your-repo/aws-automation.git
   ```
2. Configure AWS credentials:
   ```sh
   export AWS_ACCESS_KEY_ID=your-access-key
   export AWS_SECRET_ACCESS_KEY=your-secret-key
   ```
3. Deploy infrastructure with Terraform:
   ```sh
   terraform init
   terraform apply -auto-approve
   ```
4. Configure servers with Ansible:
   ```sh
   ansible-playbook -i inventory main.yml
   ```
5. Deploy the application using CI/CD pipeline.
6. Monitor the system using AWS CloudWatch.

## 📬 Contact
For any inquiries or contributions, feel free to open an issue or contact **Alejandro Herrera**.

---
🚀 **Let's build a scalable, secure, and automated cloud infrastructure!**