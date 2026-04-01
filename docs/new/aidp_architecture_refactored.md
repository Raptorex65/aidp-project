# AIDP Platform Architecture

## Overview

AIDP evolves across three stages:
1. Local (Minikube)
2. Azure AKS
3. AWS EKS

---

## Stage 1 — Local Platform Architecture

```mermaid
flowchart TB
DEV --> GIT --> CI --> GHCR --> RUNNER --> HELM --> MINIKUBE
MINIKUBE --> PG
MINIKUBE --> MINIO
MINIKUBE --> MLFLOW
MINIKUBE --> API
```

---

## Stage 2 — Azure AKS Architecture

```mermaid
flowchart TB
DEV --> TF --> AKS
DEV --> CI --> GHCR --> AZDO --> HELM --> AKS
AKS --> PG
AKS --> MINIO
AKS --> MLFLOW
AKS --> API
```

---

## Stage 3 — AWS EKS Architecture

```mermaid
flowchart TB
DEV --> TF --> EKS
DEV --> CI --> GHCR --> CP --> CB --> HELM --> EKS
EKS --> PG
EKS --> MINIO
EKS --> MLFLOW
EKS --> API
```
