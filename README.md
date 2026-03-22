# AIDP – AI Deployment Platform

AIDP is a hands-on cloud-native platform engineering project designed to demonstrate the full lifecycle of a machine learning application deployed on Kubernetes with CI/CD automation.

The project focuses on practical skills for:

- Kubernetes application deployment
- Helm packaging
- Docker image lifecycle
- GitHub Actions CI/CD
- GitHub Container Registry (GHCR)
- Self-hosted runners
- Infrastructure evolution toward cloud environments

---

## Architecture Overview

The platform consists of several services deployed on Kubernetes:

- **PostgreSQL** – metadata backend for MLflow
- **MinIO** – S3-compatible object storage
- **MLflow** – experiment tracking and model registry
- **Model API** – inference service
- **Ingress** – routing HTTP traffic

All components are deployed using **Helm**.

---

## CI/CD Workflow

### Continuous Integration (CI)

The CI pipeline performs:

1. Checkout repository
2. Validate Python code
3. Build Docker image
4. Tag image (`latest` + commit SHA)
5. Push image to **GitHub Container Registry (GHCR)**

Example image:
ghcr.io/raptorex65/aidp-model-api:<commit-sha>

---

### Continuous Deployment (CD)

Deployment runs on a **self-hosted runner**.

Steps:

1. Wait for CI workflow completion
2. Pull image from GHCR
3. Load image into Minikube
4. Deploy using Helm
5. Verify rollout

---

## Repository Structure

.github/workflows/ CI/CD pipelines
apps/ application services
charts/aidp/ Helm chart
docs/ documentation
infra/ infrastructure resources
k8s/ raw Kubernetes manifests
scripts/ helper scripts

---

## Roadmap

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
- **Phase 7 – Extending the deployment to AWS EKS for multi-cloud capability**

The local environment acts as a **development and validation layer** before moving to cloud infrastructure.

## Phase 6 => Cloud deployment on Azure AKS

Deploy the platform to Azure Kubernetes Service (AKS) using Terraform to transition from a local Kubernetes environment to a managed cloud platform.

Key objectives:

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

## Phase 7 – AWS EKS Deployment (Multi-cloud expansion to AWS EKS)

This phase extends the platform to **Amazon Web Services** to demonstrate multi-cloud portability.

The same application stack that runs on **AKS** is deployed to **Amazon EKS**.

### Infrastructure Provisioning

The Kubernetes infrastructure is created using **Terraform**.

Key resources:

- VPC
- Public and private subnets
- Amazon EKS cluster
- Managed node group
- IAM roles for cluster components

### Storage Integration (EBS CSI)

Unlike AKS, EKS does not automatically provide persistent storage integration.

To enable persistent volumes, the **AWS EBS CSI driver** must be installed.

Required components:

- `aws-ebs-csi-driver` EKS add-on
- IAM role with `AmazonEBSCSIDriverPolicy`
- OIDC identity provider for the cluster

This allows Kubernetes **PersistentVolumeClaims (PVC)** to dynamically provision **EBS volumes**.

Example:

PVC → EBS CSI driver → EBS volume

### Application Deployment

The platform is deployed using the same **Helm chart** used in earlier phases.

Services deployed:

- PostgreSQL
- MinIO
- MLflow
- Model API

Persistent storage is backed by **Amazon EBS volumes**.

### Ingress and External Access

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

## Phase 8 – Multi-Tool Continuous Delivery (AKS + EKS)

This phase introduces a **multi-environment deployment strategy** using a centralized build pipeline and cloud-specific deployment tools.

The goal is to implement a **"build once, deploy everywhere"** approach across multiple Kubernetes clusters.

---

### Architecture Overview

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

### Continuous Integration (CI)

CI is handled by **GitHub Actions**.

Responsibilities:

- Build Docker image
- Run validation checks
- Tag image using commit SHA
- Push image to **GitHub Container Registry (GHCR)**

The output of CI is a **single immutable artifact**:

ghcr.io/<repository>/aidp-model-api:<commit-sha>


This artifact is reused across all environments.

---

### Continuous Deployment (CD)

Deployment responsibilities are split across cloud-native tools.

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

### Environment Strategy

| Environment | Platform | Purpose |
|------------|--------|--------|
| AKS | Azure | Development / Testing |
| EKS | AWS | Production |

This separation reflects a realistic **multi-cloud deployment model**.

---

### Key Design Principles

#### Single Build Artifact

The Docker image is built only once and reused:

- No rebuild per environment
- Same artifact across AKS and EKS
- Ensures consistency between environments

#### Separation of CI and CD

- CI is centralized (GitHub Actions)
- CD is delegated to cloud-specific tools

#### Cloud-Native Deployment

Each platform uses its native tooling:

- Azure DevOps for AKS
- AWS CodePipeline for EKS

---

### Key Learning Outcomes

This phase demonstrates:

- Multi-cluster Kubernetes deployment
- Separation of CI and CD responsibilities
- Use of multiple DevOps platforms in a single architecture
- Immutable artifact strategy
- Real-world multi-cloud delivery pipeline design

This architecture reflects patterns commonly used in enterprise environments.