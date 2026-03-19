## CI/CD Workflow

```mermaid
flowchart LR

DEV[Developer Push]

subgraph GitHub
CI[GitHub Actions CI]
GHCR[GitHub Container Registry]
end

subgraph Deployment
RUNNER[Self Hosted Runner]
HELM[Helm Deployment]
K8S[Kubernetes Cluster]
end

DEV --> CI

CI --> BUILD[Build Docker Image]
BUILD --> TAG[Tag Image]

TAG --> GHCR

GHCR --> RUNNER

RUNNER --> HELM
HELM --> K8S
