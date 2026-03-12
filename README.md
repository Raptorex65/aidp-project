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

### Phase 1-5 (current)

- Local Kubernetes deployment (Minikube)
- Helm packaging
- GitHub Actions CI
- GHCR image registry
- Self-hosted runner CD

### Phase 6

Deploy platform to **Azure Kubernetes Service (AKS)** using Terraform.

### Phase 7

Extend deployment to **AWS EKS** for multi-cloud capability.

