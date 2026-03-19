## Infrastructure Layers

```mermaid
flowchart TB

DEV[Developer]

subgraph Infrastructure as Code
TF[Terraform]
end

subgraph Kubernetes Platforms
AKS[Azure Kubernetes Service]
EKS[Amazon EKS]
end

subgraph Application Deployment
HELM[Helm Charts]
end

subgraph Platform Services
POSTGRES[PostgreSQL]
MINIO[MinIO]
MLFLOW[MLflow]
MODELAPI[Model API]
end

DEV --> TF
TF --> AKS
TF --> EKS

AKS --> HELM
EKS --> HELM

HELM --> POSTGRES
HELM --> MINIO
HELM --> MLFLOW
HELM --> MODELAPI
