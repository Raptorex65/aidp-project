# CI/CD Diagrams

## Local
DEV → CI → GHCR → Runner → Helm → Minikube

## AKS
DEV → CI → GHCR → Azure DevOps → Helm → AKS

## EKS
DEV → CI → GHCR → CodePipeline → CodeBuild → Helm → EKS
