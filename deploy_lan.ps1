$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$frontend = Join-Path $root "React\\my-app"
$backend = Join-Path $root "sigma_api"

Write-Host "==> Building frontend (Vite)"
Push-Location $frontend
if (-not (Test-Path "node_modules")) {
  Write-Host "Installing frontend dependencies..."
  npm install
}
npm run build
Pop-Location

Write-Host "==> Starting backend (FastAPI)"
$python = Join-Path $backend "venv\\Scripts\\python.exe"
if (-not (Test-Path $python)) {
  $python = "python"
}
Push-Location $backend
& $python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
Pop-Location
