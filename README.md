# Go Echo Web Server - CI/CD Demo

이 프로젝트는 GitHub Actions를 통한 CI/CD 파이프라인과 AWS/GCP 클라우드 배포를 테스트하기 위한 Go Echo 웹 서버입니다.

## 프로젝트 목표

- ✅ Go + Echo Framework로 REST API 서버 구축
- ✅ GitHub Actions를 통한 자동 빌드 및 테스트
- ✅ 멀티 플랫폼 바이너리 배포 (Linux, Windows, macOS)
- ✅ AWS 배포 자동화
- ✅ GCP 배포 자동화

## 기술 스택

- **언어**: Go 1.21+
- **웹 프레임워크**: Echo v4
- **CI/CD**: GitHub Actions
- **클라우드**: AWS (EC2, S3), GCP (Compute Engine, Cloud Storage)

## 진행 상황

### 완료
- [x] 프로젝트 초기화
- [x] 언어/프레임워크 선택 (Go + Echo)

### 진행 중
- [ ] Go 프로젝트 구조 설정
- [ ] Echo 웹 서버 구현
- [ ] GitHub Actions 워크플로우 작성
- [ ] AWS 배포 설정
- [ ] GCP 배포 설정
- [ ] 바이너리 배포 테스트

## 로컬 실행 방법

```bash
# 의존성 설치
go mod download

# 서버 실행
go run main.go

# 빌드
go build -o server
```

## API 엔드포인트

- `GET /` - 헬스 체크
- `GET /api/v1/hello` - Hello World API

## 배포 방법

### AWS
```bash
# AWS CLI를 통한 배포 (설정 예정)
```

### GCP
```bash
# gcloud CLI를 통한 배포 (설정 예정)
```

## 라이선스

MIT
