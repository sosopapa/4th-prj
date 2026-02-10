# PowerShell 배포 스크립트 (Windows용)
# 로컬에서 EC2로 Go 바이너리를 배포합니다

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting deployment to EC2..." -ForegroundColor Green

# 설정
$EC2_HOST = "ec2-16-176-165-67.ap-southeast-2.compute.amazonaws.com"
$EC2_USER = "ubuntu"
$EC2_KEY = "vi.ai.kr.pem"
$DEPLOY_DIR = "/home/ubuntu/web"
$BINARY_NAME = "server"

# 1. 로컬 빌드
Write-Host "📦 Building binary for Linux..." -ForegroundColor Cyan
$env:GOOS = "linux"
$env:GOARCH = "amd64"
go build -o $BINARY_NAME main.go

if (-not (Test-Path $BINARY_NAME)) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green

# 2. EC2로 파일 전송
Write-Host "📤 Uploading binary to EC2..." -ForegroundColor Cyan
scp -i $EC2_KEY -o StrictHostKeyChecking=no $BINARY_NAME "${EC2_USER}@${EC2_HOST}:${DEPLOY_DIR}/"

# 3. EC2에서 배포
Write-Host "🔄 Deploying on EC2..." -ForegroundColor Cyan
$deployScript = @"
cd /home/ubuntu/web
chmod +x server
echo 'Stopping existing server...'
pkill -f './server' || true
sleep 2
echo 'Starting new server...'
nohup ./server > server.log 2>&1 &
sleep 3
if curl -f http://localhost:8080/ > /dev/null 2>&1; then
    echo '✅ Server is running!'
    curl http://localhost:8080/api/v1/info
else
    echo '❌ Server failed to start!'
    tail -n 20 server.log
    exit 1
fi
"@

ssh -i $EC2_KEY -o StrictHostKeyChecking=no "${EC2_USER}@${EC2_HOST}" $deployScript

Write-Host ""
Write-Host "🎉 Deployment successful!" -ForegroundColor Green
Write-Host "🌐 Access your server at: http://${EC2_HOST}:8080" -ForegroundColor Yellow
