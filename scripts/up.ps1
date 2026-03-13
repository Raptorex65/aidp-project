Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host "Starting local stack (Postgres + MinIO + MLflow + API)..." -ForegroundColor Cyan
docker compose -f infra/local/docker-compose.yml up -d --build

Write-Host "`nServices:" -ForegroundColor Cyan
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host "`nMLflow:      http://localhost:5000" -ForegroundColor Green
Write-Host "MinIO UI:    http://localhost:9001  (user=minio pass=minio12345)" -ForegroundColor Green
Write-Host "Model API:   http://localhost:8080/healthz" -ForegroundColor Green