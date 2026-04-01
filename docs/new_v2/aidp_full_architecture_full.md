# AIDP Multi-Environment Architecture

This diagram represents the cloud-stage target view of the project, where the same platform stack is deployed across two different managed Kubernetes environments.

- **AKS** is treated as the development environment
- **EKS** is treated as the production environment

The diagram focuses on the application and environment layout, not on every possible cloud networking implementation detail.

```mermaid
flowchart TB

    subgraph DEVENV[AKS Dev Environment]
        AKS[AKS Cluster]
        AKS_ING[NGINX Ingress]
        AKS_API[Model API]
        AKS_MLFLOW[MLflow]
        AKS_MINIO[MinIO]
        AKS_PG[PostgreSQL]

        AKS_ING --> AKS_API
        AKS_ING --> AKS_MLFLOW
        AKS_MLFLOW --> AKS_MINIO
        AKS_MLFLOW --> AKS_PG
    end

    subgraph PRODENV[EKS Prod Environment]
        EKS[EKS Cluster]
        EKS_ING[NGINX Ingress]
        EKS_API[Model API]
        EKS_MLFLOW[MLflow]
        EKS_MINIO[MinIO]
        EKS_PG[PostgreSQL]

        EKS_ING --> EKS_API
        EKS_ING --> EKS_MLFLOW
        EKS_MLFLOW --> EKS_MINIO
        EKS_MLFLOW --> EKS_PG
    end
```

## Interpretation

Both cloud environments run the same logical platform stack:

- **Ingress** routes external traffic
- **Model API** serves predictions
- **MLflow** handles experiment tracking and model lifecycle functions
- **MinIO** stores artifacts
- **PostgreSQL** stores metadata

The purpose of this diagram is to show environment parity across cloud platforms, while still preserving distinct deployment paths and infrastructure provisioning models.

## Why there are no explicit cloud load balancers here

This diagram intentionally does **not** place Azure Load Balancer or AWS ELB at the center of the architecture view.

That is because the real architectural focus of the project is:

- consistent platform stack
- reusable Helm deployment
- environment-specific CI/CD and infrastructure
- managed Kubernetes portability

Cloud-native ingress exposure can exist underneath this model, but it is not the clearest primary story for this diagram.
