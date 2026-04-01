# 🚀 AIDP – AI Deployment Platform

AIDP is a hands-on **cloud-native platform engineering project** that demonstrates the end-to-end lifecycle of a machine learning application on Kubernetes, including **CI/CD automation and multi-cloud deployment**.

The project evolves from a **local Kubernetes setup** to a **multi-cloud architecture (Azure AKS + AWS EKS)** using a consistent deployment model.

---

# 🧭 Project Overview

The goal of AIDP is to design and implement a complete ML platform that includes:

- Containerized services
- Kubernetes-based orchestration
- Helm-based deployment
- CI/CD pipelines
- Multi-cloud deployment strategy

---

# 🏗️ Architecture Overview

The platform consists of the following components:

- **PostgreSQL** → MLflow metadata storage  
- **MinIO** → S3-compatible object storage  
- **MLflow** → experiment tracking & model registry  
- **Model API** → inference service  
- **Ingress (NGINX)** → external routing  

All services are deployed using **Helm charts**.

## CI/CD Architecture

The CI/CD pipeline is split into two responsibilities:

- **Centralized CI (GitHub Actions)**
- **Distributed CD (Azure DevOps + AWS CodePipeline)**

Developer Push
↓
GitHub Actions (CI)
↓
Build Docker Image
Tag (commit SHA)
Push → GHCR
↓
──────────────────────────────
↓ ↓
Azure DevOps Pipeline AWS CodePipeline
(AKS - Dev) (EKS - Prod)
↓ ↓
Helm Deployment Helm Deployment

---
# ⚙️ CI/CD Strategy

The project follows a **“build once, deploy everywhere”** model.

## Continuous Integration (CI)
Handled by **GitHub Actions**:
- Build Docker image
- Tag (`latest` + commit SHA)
- Push to **GHCR**

Responsibilities:

- Build Docker image
- Run validation checks
- Tag image using commit SHA
- Push image to **GitHub Container Registry (GHCR)**

The output of CI is a **single immutable artifact**:

ghcr.io/<repository>/aidp-model-api:<commit-sha>

This artifact is reused across all environments.

## Continuous Deployment (CD)

Deployment is environment-specific:

- **Local** → GitHub Actions (self-hosted runner)
- **AKS** → Azure DevOps Pipelines
- **EKS** → AWS CodePipeline + CodeBuild

#### Azure DevOps (AKS – Development Environment)

- Pulls image from GHCR
- Deploys to AKS using Helm
- Uses environment-specific configuration (`values-aks-dev.yaml`)
- Performs validation and rollout checks

#### AWS CodePipeline + CodeBuild (EKS – Production Environment)

- Orchestrates deployment using CodePipeline
- Executes deployment steps in CodeBuild
- Uses Helm for Kubernetes deployment
- Applies production configuration (`values-eks-prod.yaml`)
---

# 🧱 Project Evolution

---

## 🟢 Stage 1 — Local Platform Engineering (Phase 1–5)

Built and validated the platform locally using:

- **Minikube**
- **Helm**
- **Docker**
- **GitHub Actions (CI + self-hosted CD)**

## Phase 1–5 – Local Platform Engineering (Minikube)
Sub-Phases
- Local Kubernetes deployment (Minikube)
- Helm packaging
- GitHub Actions CI
- GHCR image registry
- Self-hosted runner CD

The first phases of the project focus on building a **complete local platform engineering workflow** before moving to cloud environments.

The goal is to design and validate the **entire lifecycle of an ML platform** locally, including containerization, Kubernetes deployment, Helm packaging, and CI/CD automation.

By the end of these phases, the platform can be **built, packaged, deployed, and updated automatically** inside a local Kubernetes cluster.

---

## Local Kubernetes Environment

Development and testing are performed using **Minikube**, which provides a lightweight Kubernetes cluster running locally.

Minikube enables:

- Fast iteration during development
- Full Kubernetes API compatibility
- Testing Helm deployments before cloud migration
- Running CI/CD deployments locally

The local cluster simulates a production-like environment while keeping the feedback loop short.

---

## Application Containerization

Each application component is containerized using **Docker**.

The main application image is built from the **Model API service**, which exposes inference endpoints for machine learning models.

The container build process includes:

- Python environment setup
- Dependency installation
- Application packaging
- Runtime configuration

Images are tagged using:

- `latest`
- Git commit SHA

This tagging strategy enables traceability between code changes and deployed images.

---

## Helm-Based Kubernetes Deployment

The entire platform is deployed using a **Helm chart**.

Helm provides a reusable and parameterized way to manage Kubernetes manifests.

The Helm chart defines the deployment of the platform services:

- PostgreSQL
- MinIO
- MLflow
- Model API
- Ingress configuration

Key benefits of using Helm:

- Reusable deployments
- Parameterized configuration through `values.yaml`
- Environment portability
- Simplified upgrades and rollbacks

Helm becomes the **primary application deployment mechanism** used in all later phases.

---

## Platform Services

The platform architecture consists of several interconnected services.

### PostgreSQL

PostgreSQL acts as the **metadata database** for MLflow.

It stores:

- experiment metadata
- run history
- model registry information

Persistent storage is provisioned through Kubernetes volumes.

---

### MinIO

MinIO provides **S3-compatible object storage**.

It stores:

- model artifacts
- training outputs
- experiment files

Using MinIO locally allows the platform to simulate cloud object storage behavior.

---

### MLflow

MLflow is responsible for:

- experiment tracking
- model versioning
- model registry

It connects to:

- PostgreSQL (metadata backend)
- MinIO (artifact storage)

This separation mirrors real-world ML platform architecture.

---

### Model API

The Model API exposes a REST endpoint used for **model inference**.

It serves as the interface between users and deployed machine learning models.

Typical usage:

POST /predict


The API container image is built during CI and deployed via Helm.

---

## Ingress and HTTP Routing

External traffic is routed through an **NGINX Ingress Controller**.

Ingress allows multiple services to be exposed through a single entry point.

Example routing structure:

/api → Model API
/mlflow → MLflow UI


This structure is preserved when the platform is later deployed to cloud environments.

---

## Continuous Integration (GitHub Actions)

A **GitHub Actions workflow** automates the build pipeline.

Each commit triggers the CI process:

1. Checkout repository
2. Validate application code
3. Build Docker image
4. Tag image (`latest` + commit SHA)
5. Push image to registry

This ensures every change produces a **reproducible container image**.

---

## Container Registry (GHCR)

Container images are stored in **GitHub Container Registry (GHCR)**.

Example image reference:

ghcr.io/<repository>/aidp-model-api:<commit-sha>


Using GHCR allows the CI pipeline to:

- publish images
- version images automatically
- make images accessible to deployment environments

---

## Continuous Deployment (Self-Hosted Runner)

Deployment automation is handled by a **self-hosted GitHub Actions runner**.

The runner performs the deployment steps inside the local Kubernetes environment.

Deployment workflow:

1. Wait for CI completion
2. Pull container image from GHCR
3. Load image into Minikube
4. Deploy platform via Helm
5. Verify rollout

This approach simulates a real **CI/CD pipeline used in production environments**.

---

## Key Outcomes of Phase 1–5

By the end of these phases, the project demonstrates a complete **local platform engineering workflow**:

- Kubernetes-based platform architecture
- Containerized machine learning services
- Helm-based deployment strategy
- Automated CI pipeline
- Automated CD deployment
- Reproducible container builds
- Local simulation of a production environment

These foundations enable the next stages of the project:

- **Phase 6 – Deploying the platform to Azure AKS**
- **Phase 7-8 – Extending the deployment to AWS EKS for multi-cloud capability**

The local environment acts as a **development and validation layer** before moving to cloud infrastructure.

---

## 🔵 Stage 2 — Azure Cloud Deployment (Phase 6)

Migrated the platform to **Azure Kubernetes Service (AKS)**.
Deploy the platform to Azure Kubernetes Service (AKS) using Terraform to transition from a local Kubernetes environment to a managed cloud platform.

### Key Components

- Infrastructure → **Terraform**
- CI → GitHub Actions
- CD → **Azure DevOps Pipelines**

### Key objectives

- Provision AKS infrastructure using Infrastructure as Code (Terraform)
- Deploy Kubernetes workloads using the existing Helm chart
- Configure persistent storage using Azure managed disk storage classes
- Expose services using NGINX Ingress
- Validate external access to platform services
- This phase represents the first transition from local development (Minikube) to a cloud-managed Kubernetes environment.

Key learning points include:
- Terraform-based Kubernetes infrastructure provisioning
- Differences between local and managed Kubernetes clusters
- Azure storage integration with Kubernetes Persistent Volumes
- Cloud networking and ingress configuration

The platform stack deployed to AKS includes:
- PostgreSQL – MLflow metadata database
- MinIO – object storage for ML artifacts
- MLflow – experiment tracking and model registry
- Model API – inference endpoint
- NGINX Ingress Controller – HTTP routing

This phase establishes the foundation for cloud-native deployment, which is later extended to multi-cloud support with AWS EKS in Phase 7.

---

## 🟣 Stage 3 — AWS Cloud Deployment (Phase 7–8)

Extended the platform to **Amazon EKS** and introduced multi-cloud CD.

### Phase 7 – AWS EKS Deployment (Multi-cloud expansion to AWS EKS)

This phase extends the platform to **Amazon Web Services** to demonstrate multi-cloud portability.

The same application stack that runs on **AKS** is deployed to **Amazon EKS**.

#### Infrastructure Provisioning

The Kubernetes infrastructure is created using **Terraform**.

Key resources:

- VPC
- Public and private subnets
- Amazon EKS cluster
- Managed node group
- IAM roles for cluster components

#### Storage Integration (EBS CSI)

Unlike AKS, EKS does not automatically provide persistent storage integration.

To enable persistent volumes, the **AWS EBS CSI driver** must be installed.

Required components:

- `aws-ebs-csi-driver` EKS add-on
- IAM role with `AmazonEBSCSIDriverPolicy`
- OIDC identity provider for the cluster

This allows Kubernetes **PersistentVolumeClaims (PVC)** to dynamically provision **EBS volumes**.

Example:

PVC → EBS CSI driver → EBS volume

#### Application Deployment

The platform is deployed using the same **Helm chart** used in earlier phases.

Services deployed:

- PostgreSQL
- MinIO
- MLflow
- Model API

Persistent storage is backed by **Amazon EBS volumes**.

#### Ingress and External Access

Traffic is routed through:
Internet
↓
AWS Elastic Load Balancer (ELB)
↓
NGINX Ingress Controller
↓
Kubernetes Services
↓
Application Pods


The load balancer is automatically created when the **NGINX ingress controller service is exposed as `LoadBalancer`**.

Example access pattern:

http://<ELB-DNS>/api
http://<ELB-DNS>/mlflow

### Phase 8 – Multi-Tool Continuous Delivery (AKS + EKS)

This phase introduces a **multi-environment deployment strategy** using a centralized build pipeline and cloud-specific deployment tools.

The goal is to implement a **"build once, deploy everywhere"** approach across multiple Kubernetes clusters.

### Infrastructure

- VPC, subnets, EKS → Terraform
- Node groups + IAM roles

### Storage

- **EBS CSI driver**
- Dynamic volume provisioning

### CD Strategy

- **CodePipeline → orchestration**
- **CodeBuild → Helm deployment**

### Multi-Cloud Model

| Environment | Platform | Purpose |
|------------|--------|--------|
| AKS | Azure | Development |
| EKS | AWS | Production |

---

# 🎯 Key Design Principles

- **Build Once, Deploy Everywhere**
- **Separation of CI and CD**
- **Cloud-native tooling per platform**
- **Reusable Helm-based deployments**
- **Immutable artifact strategy**

---

# 🧠 Lessons Learned

- Kubernetes failures are almost always configuration issues  
- Helm enables scalable and reusable deployment architecture  
- Cloud providers differ significantly despite Kubernetes abstraction  
- Stateful workloads require careful storage handling  
- CI/CD is a maturity model, not just tooling  
- Debugging is a critical engineering skill  

---

# 🛠️ Appendix — Deployment Challenges & Resolutions

## PostgreSQL – CrashLoopBackOff

**Issue:**
PostgreSQL failed due to non-empty data directory (`lost+found`).

**Solution:**
Configured `PGDATA` to use a subdirectory.

---

## MLflow – ImagePullBackOff

**Issue:**
Incorrect image reference in Helm values.

**Solution:**
Corrected GHCR image repository and tag.

---

## MinIO Init Job – InvalidImageName

**Issue:**
Incorrect Helm template image reference.

**Solution:**
Separated MinIO server and client images.

---

## Persistent Volume Issues

**Issue:**
Incorrect `storageClassName` placement.

**Solution:**
Fixed YAML structure and used correct storage class.

---

## IAM & Access Model (EKS)

No additional IAM access entries required because:

- Cluster accessed via kubeconfig
- Storage handled via EBS CSI
- No AWS-native service dependency (used MinIO)

---

## ✅ Final Outcome

| Component | Status |
|----------|-------|
| PostgreSQL | ✅ Running |
| MinIO | ✅ Running |
| MLflow | ✅ Running |
| Model API | ✅ Running |
| PVC (EBS) | ✅ Bound |
| Helm Deployment | ✅ Successful |

---

## 🚀 Summary

This project demonstrates:

- Multi-cluster Kubernetes deployment
- Multi-cloud platform architecture (AKS + EKS)
- CI/CD separation and orchestration
- Helm-based reusable deployment model
- Real-world debugging and problem resolution

It reflects patterns commonly used in **production-grade cloud-native systems**.

