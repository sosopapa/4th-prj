# 프로젝트 구조

```
4th_prj/
├── .git/                      # Git 저장소
├── .github/
│   └── workflows/             # GitHub Actions 워크플로우
│       ├── build.yml          # 빌드 및 테스트 자동화
│       ├── release.yml        # 멀티 플랫폼 릴리즈 자동화
│       ├── deploy-aws.yml     # AWS 배포 자동화
│       └── deploy-gcp.yml     # GCP 배포 자동화
│
├── bin/                       # 빌드 출력 디렉토리 (생성 예정)
│
├── .gitignore                 # Git 제외 파일 목록
├── Dockerfile                 # Docker 이미지 빌드 설정
├── Makefile                   # 빌드 자동화 스크립트
│
├── go.mod                     # Go 모듈 정의
├── go.sum                     # Go 의존성 체크섬
├── main.go                    # 메인 애플리케이션 코드
│
├── README.md                  # 프로젝트 개요 및 소개
├── SETUP.md                   # 개발 환경 설정 가이드
├── DEPLOYMENT.md              # 클라우드 배포 가이드
├── PROJECT_STATUS.md          # 프로젝트 진행 상황 추적
└── PROJECT_STRUCTURE.md       # 이 파일
```

## 파일 설명

### 핵심 애플리케이션 파일

- **[main.go](main.go)**: Go Echo 웹 서버 구현
  - Echo 프레임워크 기반
  - REST API 엔드포인트 3개
  - 미들웨어 설정 (Logger, Recover, CORS)

- **[go.mod](go.mod)**, **[go.sum](go.sum)**: Go 의존성 관리
  - Echo v4.11.4
  - 필요한 모든 의존성 정의

### 빌드 및 배포 파일

- **[Dockerfile](Dockerfile)**: 멀티 스테이지 Docker 빌드
  - 빌드 스테이지: Go 1.21 Alpine
  - 실행 스테이지: Alpine Latest
  - 최적화된 경량 이미지

- **[Makefile](Makefile)**: 빌드 자동화
  - `make build`: 단일 플랫폼 빌드
  - `make build-all`: 멀티 플랫폼 빌드 (5개 플랫폼)
  - `make run`: 서버 실행
  - `make test`: 테스트 실행
  - `make docker-build`: Docker 이미지 빌드

### GitHub Actions 워크플로우

1. **[build.yml](.github/workflows/build.yml)**
   - 트리거: push/PR to main, develop
   - 동작: 빌드, 테스트, 아티팩트 업로드

2. **[release.yml](.github/workflows/release.yml)**
   - 트리거: v* 태그 push
   - 동작: 5개 플랫폼 빌드, GitHub Release 생성

3. **[deploy-aws.yml](.github/workflows/deploy-aws.yml)**
   - 트리거: push to main
   - 동작: S3 업로드, EC2 배포

4. **[deploy-gcp.yml](.github/workflows/deploy-gcp.yml)**
   - 트리거: push to main
   - 동작: Cloud Storage 업로드, Compute Engine 배포

### 문서 파일

- **[README.md](README.md)**: 프로젝트 개요
  - 프로젝트 목표 및 기술 스택
  - 빠른 시작 가이드
  - API 엔드포인트 목록

- **[SETUP.md](SETUP.md)**: 개발 환경 설정
  - Go 설치 방법 (Windows/macOS/Linux)
  - 로컬 개발 가이드
  - 빌드 및 테스트 방법
  - Docker 사용법

- **[DEPLOYMENT.md](DEPLOYMENT.md)**: 배포 가이드
  - GitHub Secrets 설정
  - AWS 배포 상세 가이드
  - GCP 배포 상세 가이드
  - 트러블슈팅

- **[PROJECT_STATUS.md](PROJECT_STATUS.md)**: 진행 상황
  - 완료된 작업 목록
  - 진행 중인 작업
  - 남은 작업 및 로드맵

## API 엔드포인트

애플리케이션은 다음 REST API를 제공합니다:

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/` | 헬스 체크 |
| GET | `/api/v1/hello` | Hello World API (query: name) |
| GET | `/api/v1/info` | 서버 정보 및 API 목록 |

## 빌드 출력 (멀티 플랫폼)

`make build-all` 또는 GitHub Actions Release 시 다음 바이너리가 생성됩니다:

- `server-linux-amd64` (Linux x86_64)
- `server-linux-arm64` (Linux ARM64)
- `server-darwin-amd64` (macOS Intel)
- `server-darwin-arm64` (macOS Apple Silicon)
- `server-windows-amd64.exe` (Windows x86_64)

## 환경 변수

- `PORT`: 서버 포트 (기본값: 8080)

## 다음 단계

1. **Git 설정 및 커밋**
   ```bash
   git config --global user.email "your.email@example.com"
   git config --global user.name "Your Name"
   git commit -m "Initial commit"
   ```

2. **GitHub 저장소 생성 및 푸시**
   ```bash
   gh repo create 4th-prj --public --source=. --remote=origin
   git push -u origin main
   ```

3. **로컬 테스트** (Go 설치 후)
   ```bash
   go run main.go
   ```

자세한 내용은 각 문서 파일을 참고하세요.
