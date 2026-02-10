# 배포 가이드

이 문서는 AWS와 GCP에 바이너리를 배포하기 위한 설정 방법을 설명합니다.

## 목차
1. [GitHub Secrets 설정](#github-secrets-설정)
2. [AWS 배포 설정](#aws-배포-설정)
3. [GCP 배포 설정](#gcp-배포-설정)
4. [워크플로우 설명](#워크플로우-설명)

---

## GitHub Secrets 설정

GitHub 저장소의 Settings > Secrets and variables > Actions에서 다음 secrets를 추가하세요.

### AWS 관련 Secrets

| Secret 이름 | 설명 | 예시 |
|------------|------|------|
| `AWS_ACCESS_KEY_ID` | AWS IAM 액세스 키 ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM 시크릿 액세스 키 | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_S3_BUCKET` | 바이너리 저장용 S3 버킷 이름 | `my-app-binaries` |
| `EC2_HOST` | EC2 인스턴스 퍼블릭 IP 또는 도메인 | `ec2-xxx-xxx-xxx-xxx.compute.amazonaws.com` |
| `EC2_USERNAME` | EC2 SSH 사용자명 | `ec2-user` 또는 `ubuntu` |
| `EC2_SSH_KEY` | EC2 SSH 프라이빗 키 (PEM 형식) | `-----BEGIN RSA PRIVATE KEY-----\n...` |

### GCP 관련 Secrets

| Secret 이름 | 설명 | 예시 |
|------------|------|------|
| `GCP_SA_KEY` | GCP Service Account JSON 키 | `{"type": "service_account", ...}` |
| `GCS_BUCKET` | 바이너리 저장용 Cloud Storage 버킷 | `my-app-binaries` |
| `GCE_INSTANCE_NAME` | Compute Engine 인스턴스 이름 | `my-app-server` |
| `GCE_ZONE` | Compute Engine 인스턴스 존 | `asia-northeast3-a` |

---

## AWS 배포 설정

### 1. IAM 사용자 생성

```bash
# AWS CLI로 IAM 사용자 생성
aws iam create-user --user-name github-actions-deployer

# S3 및 EC2 권한 부여
aws iam attach-user-policy \
  --user-name github-actions-deployer \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# 액세스 키 생성
aws iam create-access-key --user-name github-actions-deployer
```

### 2. S3 버킷 생성

```bash
# S3 버킷 생성
aws s3 mb s3://my-app-binaries --region ap-northeast-2

# 버킷 정책 설정 (선택사항)
cat > bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT_ID:user/github-actions-deployer"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-app-binaries/*"
    }
  ]
}
EOF

aws s3api put-bucket-policy \
  --bucket my-app-binaries \
  --policy file://bucket-policy.json
```

### 3. EC2 인스턴스 설정

```bash
# EC2 인스턴스 생성 (Amazon Linux 2)
aws ec2 run-instances \
  --image-id ami-0c9c942bd7bf113a2 \
  --instance-type t2.micro \
  --key-name my-key-pair \
  --security-groups my-security-group

# 인스턴스에 SSH 접속
ssh -i my-key-pair.pem ec2-user@EC2_PUBLIC_IP

# 인스턴스에 AWS CLI 설치 및 설정
sudo yum update -y
sudo yum install -y aws-cli

# IAM 역할로 S3 접근 권한 부여 (권장)
aws configure
```

### 4. 보안 그룹 설정

```bash
# HTTP 포트 8080 허용
aws ec2 authorize-security-group-ingress \
  --group-name my-security-group \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0
```

---

## GCP 배포 설정

### 1. Service Account 생성

```bash
# GCP 프로젝트 설정
export PROJECT_ID=my-project-id
gcloud config set project $PROJECT_ID

# Service Account 생성
gcloud iam service-accounts create github-actions-deployer \
  --display-name "GitHub Actions Deployer"

# 권한 부여
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:github-actions-deployer@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:github-actions-deployer@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/compute.instanceAdmin.v1"

# JSON 키 생성
gcloud iam service-accounts keys create key.json \
  --iam-account=github-actions-deployer@${PROJECT_ID}.iam.gserviceaccount.com
```

### 2. Cloud Storage 버킷 생성

```bash
# 버킷 생성
gsutil mb -p $PROJECT_ID -l asia-northeast3 gs://my-app-binaries

# 버킷 권한 설정
gsutil iam ch \
  serviceAccount:github-actions-deployer@${PROJECT_ID}.iam.gserviceaccount.com:objectAdmin \
  gs://my-app-binaries
```

### 3. Compute Engine 인스턴스 생성

```bash
# 인스턴스 생성
gcloud compute instances create my-app-server \
  --zone=asia-northeast3-a \
  --machine-type=e2-micro \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --service-account=github-actions-deployer@${PROJECT_ID}.iam.gserviceaccount.com \
  --scopes=storage-rw,compute-rw

# 방화벽 규칙 생성
gcloud compute firewall-rules create allow-app-port \
  --allow=tcp:8080 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server

# 인스턴스에 태그 추가
gcloud compute instances add-tags my-app-server \
  --zone=asia-northeast3-a \
  --tags=http-server
```

### 4. SSH 키 설정

```bash
# SSH 키 생성
ssh-keygen -t rsa -f ~/.ssh/gcp-key -C "github-actions"

# 공개 키를 GCE 인스턴스에 추가
gcloud compute instances add-metadata my-app-server \
  --zone=asia-northeast3-a \
  --metadata-from-file ssh-keys=<(echo "github-actions:$(cat ~/.ssh/gcp-key.pub)")
```

---

## 워크플로우 설명

### 1. Build and Test (`.github/workflows/build.yml`)

- **트리거**: `main`, `develop` 브랜치에 push 또는 PR
- **동작**:
  - Go 환경 설정
  - 의존성 다운로드
  - 테스트 실행
  - 바이너리 빌드
  - 아티팩트 업로드

### 2. Release Binaries (`.github/workflows/release.yml`)

- **트리거**: `v*` 태그 push 또는 수동 실행
- **동작**:
  - 멀티 플랫폼 빌드 (Linux, macOS, Windows)
  - GitHub Release 생성
  - 모든 플랫폼 바이너리 첨부

**릴리즈 생성 방법**:
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### 3. Deploy to AWS (`.github/workflows/deploy-aws.yml`)

- **트리거**: `main` 브랜치에 push 또는 수동 실행
- **동작**:
  - Linux 바이너리 빌드
  - S3에 업로드
  - EC2 인스턴스에 SSH로 배포
  - 서버 재시작 및 헬스 체크

### 4. Deploy to GCP (`.github/workflows/deploy-gcp.yml`)

- **트리거**: `main` 브랜치에 push 또는 수동 실행
- **동작**:
  - Linux 바이너리 빌드
  - Cloud Storage에 업로드
  - Compute Engine 인스턴스에 배포
  - 서버 재시작 및 헬스 체크

---

## 배포 테스트

### 로컬 테스트

```bash
# 로컬에서 빌드
make build

# 실행
./bin/server

# 헬스 체크
curl http://localhost:8080/
curl http://localhost:8080/api/v1/hello?name=World
curl http://localhost:8080/api/v1/info
```

### AWS 배포 테스트

```bash
# S3에 수동 업로드
aws s3 cp bin/server s3://my-app-binaries/test/server

# EC2에서 다운로드 및 실행
ssh -i key.pem ec2-user@EC2_HOST
aws s3 cp s3://my-app-binaries/test/server ~/server
chmod +x ~/server
./server
```

### GCP 배포 테스트

```bash
# Cloud Storage에 수동 업로드
gsutil cp bin/server gs://my-app-binaries/test/server

# GCE에서 다운로드 및 실행
gcloud compute ssh my-app-server --zone=asia-northeast3-a
gsutil cp gs://my-app-binaries/test/server ~/server
chmod +x ~/server
./server
```

---

## 트러블슈팅

### AWS 관련

- **권한 오류**: IAM 정책이 올바르게 설정되었는지 확인
- **SSH 연결 실패**: 보안 그룹에서 SSH(22) 포트가 열려 있는지 확인
- **S3 업로드 실패**: 버킷 이름과 리전이 올바른지 확인

### GCP 관련

- **Service Account 권한 오류**: IAM 역할이 올바르게 부여되었는지 확인
- **SSH 연결 실패**: 방화벽 규칙에서 SSH(22) 포트가 열려 있는지 확인
- **Cloud Storage 업로드 실패**: 버킷 권한과 Service Account 권한 확인

---

## 다음 단계

1. ✅ GitHub에 저장소 생성
2. ✅ Secrets 설정
3. ✅ 클라우드 리소스 생성
4. ✅ 첫 배포 테스트
5. 모니터링 및 로깅 설정 (CloudWatch, Cloud Logging)
6. CI/CD 파이프라인 최적화
