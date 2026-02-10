#!/bin/bash

# EC2 배포 스크립트
# 로컬에서 EC2로 Go 바이너리를 배포합니다

set -e

echo "🚀 Starting deployment to EC2..."

# 설정
EC2_HOST="ec2-16-176-165-67.ap-southeast-2.compute.amazonaws.com"
EC2_USER="ubuntu"
EC2_KEY="vi.ai.kr.pem"
DEPLOY_DIR="/home/ubuntu/web"
BINARY_NAME="server"

# 1. 로컬 빌드
echo "📦 Building binary for Linux..."
GOOS=linux GOARCH=amd64 go build -o ${BINARY_NAME} main.go

if [ ! -f "${BINARY_NAME}" ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"

# 2. EC2로 파일 전송
echo "📤 Uploading binary to EC2..."
scp -i ${EC2_KEY} -o StrictHostKeyChecking=no ${BINARY_NAME} ${EC2_USER}@${EC2_HOST}:${DEPLOY_DIR}/

# 3. EC2에서 기존 서버 중지 및 새 서버 시작
echo "🔄 Deploying on EC2..."
ssh -i ${EC2_KEY} -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << 'ENDSSH'
cd /home/ubuntu/web

# 실행 권한 부여
chmod +x server

# 기존 프로세스 종료
echo "Stopping existing server..."
pkill -f './server' || true
sleep 2

# 새 서버 시작 (백그라운드)
echo "Starting new server..."
nohup ./server > server.log 2>&1 &

# 서버 시작 대기
sleep 3

# 헬스 체크
if curl -f http://localhost:8080/ > /dev/null 2>&1; then
    echo "✅ Server is running!"
    curl http://localhost:8080/api/v1/info
else
    echo "❌ Server failed to start!"
    tail -n 20 server.log
    exit 1
fi
ENDSSH

echo ""
echo "🎉 Deployment successful!"
echo "🌐 Access your server at: http://${EC2_HOST}:8080"
