# 프로젝트 설정 가이드

## 개발 환경 준비

### 1. Go 설치

#### Windows
```powershell
# Chocolatey 사용
choco install golang

# 또는 공식 웹사이트에서 다운로드
# https://go.dev/dl/
```

#### macOS
```bash
# Homebrew 사용
brew install go
```

#### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install golang-go

# 또는 최신 버전 설치
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```

### 2. Go 설치 확인

```bash
go version
# 출력: go version go1.21.0 ...
```

### 3. 프로젝트 의존성 설치

```bash
# 프로젝트 디렉토리로 이동
cd 4th_prj

# 의존성 다운로드
go mod download

# 의존성 정리
go mod tidy
```

## 로컬 개발

### 서버 실행

```bash
# 방법 1: go run
go run main.go

# 방법 2: 빌드 후 실행
go build -o server main.go
./server  # Windows: server.exe

# 방법 3: Make 사용 (Linux/macOS)
make run
```

### 환경 변수 설정

```bash
# 포트 변경 (기본값: 8080)
export PORT=3000
go run main.go

# Windows
set PORT=3000
go run main.go
```

### API 테스트

```bash
# 헬스 체크
curl http://localhost:8080/

# Hello API
curl http://localhost:8080/api/v1/hello
curl http://localhost:8080/api/v1/hello?name=Developer

# 서버 정보
curl http://localhost:8080/api/v1/info
```

## 빌드

### 단일 플랫폼 빌드

```bash
# 현재 플랫폼용 빌드
go build -o server main.go

# Make 사용
make build
```

### 멀티 플랫폼 빌드

```bash
# Make 사용 (권장)
make build-all

# 수동 빌드
GOOS=linux GOARCH=amd64 go build -o server-linux-amd64 main.go
GOOS=darwin GOARCH=amd64 go build -o server-darwin-amd64 main.go
GOOS=windows GOARCH=amd64 go build -o server-windows-amd64.exe main.go
```

## 테스트

### 테스트 실행

```bash
# 모든 테스트 실행
go test ./...

# 상세 출력
go test -v ./...

# 커버리지 확인
go test -cover ./...

# Make 사용
make test
```

### 테스트 작성 예시

[main_test.go](main_test.go) 참고 (예정)

## Docker

### Docker 빌드

```bash
# 이미지 빌드
docker build -t go-echo-server:latest .

# Make 사용
make docker-build
```

### Docker 실행

```bash
# 컨테이너 실행
docker run -p 8080:8080 go-echo-server:latest

# 백그라운드 실행
docker run -d -p 8080:8080 --name my-server go-echo-server:latest

# 로그 확인
docker logs my-server

# 컨테이너 중지
docker stop my-server

# 컨테이너 제거
docker rm my-server
```

## GitHub 설정

### 1. GitHub 저장소 생성

```bash
# GitHub CLI 사용
gh repo create 4th-prj --public --source=. --remote=origin

# 또는 웹에서 생성 후
git remote add origin https://github.com/YOUR_USERNAME/4th-prj.git
```

### 2. 코드 푸시

```bash
# 모든 파일 추가
git add .

# 커밋
git commit -m "Initial commit: Go Echo server with CI/CD"

# 푸시
git push -u origin main
```

### 3. GitHub Actions 활성화

GitHub 저장소의 Actions 탭에서 워크플로우가 자동으로 활성화됩니다.

### 4. GitHub Secrets 설정

[DEPLOYMENT.md](DEPLOYMENT.md#github-secrets-설정) 참고

## 다음 단계

### 즉시 가능한 작업

1. **로컬 테스트**
   ```bash
   go run main.go
   curl http://localhost:8080/api/v1/hello
   ```

2. **GitHub 저장소 생성 및 푸시**
   ```bash
   gh repo create 4th-prj --public --source=. --remote=origin
   git add .
   git commit -m "Initial commit"
   git push -u origin main
   ```

3. **GitHub Actions 확인**
   - 저장소의 Actions 탭에서 빌드 상태 확인

### 클라우드 배포 (선택사항)

1. **AWS 설정**
   - [DEPLOYMENT.md의 AWS 섹션](DEPLOYMENT.md#aws-배포-설정) 참고
   - S3 버킷 생성
   - EC2 인스턴스 생성
   - GitHub Secrets 설정

2. **GCP 설정**
   - [DEPLOYMENT.md의 GCP 섹션](DEPLOYMENT.md#gcp-배포-설정) 참고
   - Cloud Storage 버킷 생성
   - Compute Engine 인스턴스 생성
   - Service Account 키 설정

3. **배포 테스트**
   - `main` 브랜치에 푸시하여 자동 배포 트리거
   - 또는 GitHub Actions에서 수동 워크플로우 실행

### 추가 기능 구현

- [ ] 데이터베이스 연동 (PostgreSQL, MongoDB 등)
- [ ] 인증/인가 (JWT, OAuth 등)
- [ ] 로깅 및 모니터링 (Prometheus, Grafana)
- [ ] API 문서화 (Swagger/OpenAPI)
- [ ] 단위 테스트 및 통합 테스트 작성

## 참고 자료

- [Echo Framework 공식 문서](https://echo.labstack.com/)
- [Go 공식 문서](https://go.dev/doc/)
- [GitHub Actions 문서](https://docs.github.com/en/actions)
- [AWS 배포 가이드](https://docs.aws.amazon.com/)
- [GCP 배포 가이드](https://cloud.google.com/docs)
