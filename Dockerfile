# 빌드 스테이지
FROM golang:1.21-alpine AS builder

WORKDIR /app

# 의존성 복사 및 다운로드
COPY go.mod go.sum ./
RUN go mod download

# 소스 코드 복사
COPY . .

# 바이너리 빌드
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server main.go

# 실행 스테이지
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# 빌드된 바이너리 복사
COPY --from=builder /app/server .

# 포트 노출
EXPOSE 8080

# 실행
CMD ["./server"]
