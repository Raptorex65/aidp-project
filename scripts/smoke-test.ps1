Write-Host "Health check..." -ForegroundColor Cyan
curl.exe -s http://localhost:8080/healthz
Write-Host "`n"

Write-Host "Predict test..." -ForegroundColor Cyan
curl.exe -s -X POST http://localhost:8080/predict `
  -H "Content-Type: application/json" `
  -d "{\"sepal_length\":5.1,\"sepal_width\":3.5,\"petal_length\":1.4,\"petal_width\":0.2}"
Write-Host "`n"