.PHONY: build run test clean docker-build

# 변수 설정
BINARY_NAME=server
MAIN_PATH=main.go
BUILD_DIR=bin

# 기본 타겟
all: build

# 의존성 다운로드
deps:
	go mod download
	go mod tidy

# 빌드
build:
	go build -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_PATH)

# 멀티 플랫폼 빌드
build-all:
	@echo "Building for multiple platforms..."
	GOOS=linux GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 $(MAIN_PATH)
	GOOS=linux GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 $(MAIN_PATH)
	GOOS=darwin GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 $(MAIN_PATH)
	GOOS=darwin GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 $(MAIN_PATH)
	GOOS=windows GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe $(MAIN_PATH)
	@echo "Build complete!"

# 실행
run:
	go run $(MAIN_PATH)

# 테스트
test:
	go test -v ./...

# 클린
clean:
	rm -rf $(BUILD_DIR)
	go clean

# Docker 빌드
docker-build:
	docker build -t $(BINARY_NAME):latest .
