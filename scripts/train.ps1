Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host "Running trainer (logs to MLflow)..." -ForegroundColor Cyan

docker build -t aidp-trainer -f apps/trainer/Dockerfile .

docker run --rm `
  -e MLFLOW_TRACKING_URI="http://localhost:5000" `
  -e MODEL_NAME="iris-classifier" `
  -e MLFLOW_S3_ENDPOINT_URL="http://localhost:9000" `
  -e AWS_ACCESS_KEY_ID="minio" `
  -e AWS_SECRET_ACCESS_KEY="minio12345" `
  aidp-trainer