# AIDP Platform Architecture

## Overview

AIDP (AI Deployment Platform) is a hands-on cloud-native platform engineering project designed to demonstrate a full application lifecycle:

1. Model training
2. Experiment tracking
3. Artifact storage
4. Containerized inference service
5. Kubernetes deployment
6. CI/CD automation

The platform is currently implemented on **local Kubernetes (Minikube)** and gradually evolving toward **managed cloud Kubernetes (AKS / EKS)**.

The project focuses on improving practical skills in:

- Kubernetes
- Helm packaging
- Docker image lifecycle
- GitHub Actions CI/CD
- GitOps-style deployment patterns
- Infrastructure-as-Code progression

---

# High-Level Architecture

The platform consists of several interconnected services deployed on Kubernetes.

            +--------------------+
            |   GitHub Repo      |
            |  Source + Helm     |
            +---------+----------+
                      |
                      | Git push
                      v
            +----------------------+
            | GitHub Actions (CI)  |
            | Build Docker Image   |
            | Push to GHCR         |
            +----------+-----------+
                       |
                       v
            +----------------------+
            | GitHub Container     |
            | Registry (GHCR)      |
            +----------+-----------+
                       |
                       v
            +------------------------------+
            | CD Workflow (Self-hosted)    |
            | Pull image from GHCR         |
            | Load image into Minikube     |
            | Helm deploy/update           |
            +---------------+--------------+
                            |
                            v
                 Kubernetes Cluster
                       (Minikube)
                            |
    --------------------------------------------------
    |            |              |             |
    v            v              v             v


---

# Core Platform Components

## PostgreSQL

PostgreSQL is used as the **backend metadata store for MLflow**.

It stores:

- experiment metadata
- model versions
- run tracking data

---

## MinIO

MinIO is used as **object storage for model artifacts**.

It stores:

- trained models
- experiment outputs
- serialized model files

MinIO acts as an **S3-compatible storage backend**.

---

## MLflow

MLflow provides experiment tracking and model management.

It enables:

- logging training runs
- storing artifacts
- registering model versions
- retrieving models for deployment

---

## Model API

The Model API is a lightweight Python service responsible for:

- loading a trained model
- exposing an HTTP prediction endpoint
- serving inference requests

This component is containerized and deployed to Kubernetes.

---

# Kubernetes Layer

All platform components are deployed to Kubernetes.

Services include:

- PostgreSQL
- MinIO
- MLflow
- Model API
- Ingress controller routing

The Kubernetes resources are packaged using **Helm**.

Helm provides:

- templated Kubernetes manifests
- parameterized configuration
- versioned application releases

---

# Helm Deployment

The Helm chart located in:


---

# Core Platform Components

## PostgreSQL

PostgreSQL is used as the **backend metadata store for MLflow**.

It stores:

- experiment metadata
- model versions
- run tracking data

---

## MinIO

MinIO is used as **object storage for model artifacts**.

It stores:

- trained models
- experiment outputs
- serialized model files

MinIO acts as an **S3-compatible storage backend**.

---

## MLflow

MLflow provides experiment tracking and model management.

It enables:

- logging training runs
- storing artifacts
- registering model versions
- retrieving models for deployment

---

## Model API

The Model API is a lightweight Python service responsible for:

- loading a trained model
- exposing an HTTP prediction endpoint
- serving inference requests

This component is containerized and deployed to Kubernetes.

---

# Kubernetes Layer

All platform components are deployed to Kubernetes.

Services include:

- PostgreSQL
- MinIO
- MLflow
- Model API
- Ingress controller routing

The Kubernetes resources are packaged using **Helm**.

Helm provides:

- templated Kubernetes manifests
- parameterized configuration
- versioned application releases

---

# Helm Deployment

The Helm chart located in:
charts/aidp

contains templates for:

- postgres deployment
- minio deployment
- mlflow deployment
- model-api deployment
- ingress configuration

Helm allows:

contains templates for:

- postgres deployment
- minio deployment
- mlflow deployment
- model-api deployment
- ingress configuration

Helm allows:
helm upgrade --install aidp-helm ./charts/aidp

which provides a reproducible and upgradeable deployment process.

---

# CI/CD Architecture

The project implements a CI/CD pipeline using **GitHub Actions**.

The workflows are located in:
.github/workflows/


Two main pipelines exist:

CI → build and publish container image
CD → deploy updated image to Kubernetes

---

# Continuous Integration (CI)

Workflow:
ci.yaml
CI is triggered on:
push → main branch

Pipeline stages:

1. Checkout repository
2. Install Python dependencies
3. Run Python syntax validation
4. Build Docker image
5. Tag image

Tags include:
latest
short git SHA


ghcr.io/raptorex65/aidp-model-api:abc1234

6. Push image to **GitHub Container Registry (GHCR)**

---

# Continuous Deployment (CD)

Deployment workflow:
cd-dev.yaml

This workflow is triggered automatically when the CI workflow finishes.

Example trigger configuration:


workflow_run:
workflows: ["CI - Build and Push Model API"]
types: [completed]


The deployment job only runs if the CI workflow finished successfully.

Example condition:


if: github.event.workflow_run.conclusion == 'success'

This workflow is triggered automatically when the CI workflow finishes.

Example trigger configuration:


workflow_run:
workflows: ["CI - Build and Push Model API"]
types: [completed]


The deployment job only runs if the CI workflow finished successfully.

Example condition:

if: github.event.workflow_run.conclusion == 'success'


The CD pipeline performs the following actions:

1. Checkout repository
2. Verify required local tools
3. Extract the CI commit SHA
4. Login to GHCR
5. Pull container image
6. Load image into Minikube
7. Deploy application using Helm
8. Wait for Kubernetes rollout
9. Display running pods


# Local Deployment Environment

Currently the platform runs on:
Minikube

Images are loaded directly into Minikube during deployment.

---

# Security and Registry Integration

Container images are stored in:
GitHub Container Registry (GHCR)

Authentication is handled using:
GITHUB_TOKEN

Permissions used in the workflow:
contents: read
packages: read

# Future Architecture Evolution

The current platform architecture is intentionally designed to evolve.

## Phase 6 — Azure AKS with Terraform

The next stage introduces:

- AKS managed Kubernetes
- Terraform provisioning
- cloud networking integration
- managed identity authentication

Goals:

- move from local cluster to managed Kubernetes
- strengthen Azure platform architecture skills
- implement Infrastructure-as-Code practices

---

## Phase 7 — AWS EKS with Terraform

The final phase introduces multi-cloud capability.

Goals:

- deploy the same platform to EKS
- compare Azure and AWS Kubernetes architectures
- implement multi-cloud deployment patterns
- extend CI/CD pipelines to support multiple environments

---

# Key Design Principles

The architecture follows several core principles:

## Reproducible deployments

Helm templates ensure deployments are consistent and versioned.

---

## Immutable container images

CI builds versioned container images stored in a registry.

---

## CI/CD separation

CI is responsible for building artifacts.
CD is responsible for deployment automation.

---

## Infrastructure evolution

The project intentionally evolves through stages:


local kubernetes
→ managed kubernetes
→ multi-cloud kubernetes


This approach builds practical operational knowledge incrementally

---

# Project Value

This platform demonstrates real-world capabilities in:

- Kubernetes deployment engineering
- CI/CD automation
- container lifecycle management
- Helm packaging
- DevOps workflow design
- platform architecture thinking

It is designed as a **learning platform that mirrors real production patterns used in cloud-native environments**.
