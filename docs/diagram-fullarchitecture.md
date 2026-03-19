## Architecture Overview

```mermaid
flowchart TB

Users[Users / Clients]

subgraph Internet
LB1[AWS ELB]
LB2[Azure Load Balancer]
end

subgraph AWS
EKS[EKS Cluster]
NGINX1[NGINX Ingress]
API1[Model API]
MLFLOW1[MLflow]
MINIO1[MinIO]
PG1[PostgreSQL]
end

subgraph Azure
AKS[AKS Cluster]
NGINX2[NGINX Ingress]
API2[Model API]
MLFLOW2[MLflow]
MINIO2[MinIO]
PG2[PostgreSQL]
end

Users --> LB1
Users --> LB2

LB1 --> NGINX1
LB2 --> NGINX2

NGINX1 --> API1
NGINX1 --> MLFLOW1

NGINX2 --> API2
NGINX2 --> MLFLOW2

MLFLOW1 --> PG1
MLFLOW1 --> MINIO1

MLFLOW2 --> PG2
MLFLOW2 --> MINIO2
