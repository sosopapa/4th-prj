package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	// Echo 인스턴스 생성
	e := echo.New()

	// 미들웨어 설정
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORS())

	// 라우트 설정
	e.GET("/", healthCheck)
	e.GET("/api/v1/hello", helloHandler)
	e.GET("/api/v1/info", infoHandler)

	// 서버 포트 설정
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// 서버 시작
	e.Logger.Fatal(e.Start(":" + port))
}

// healthCheck - 헬스 체크 엔드포인트
func healthCheck(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]interface{}{
		"status":  "healthy",
		"message": "Server is running",
	})
}

// helloHandler - Hello World API
func helloHandler(c echo.Context) error {
	name := c.QueryParam("name")
	if name == "" {
		name = "World"
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"message": fmt.Sprintf("Hello, %s!", name),
		"version": "1.0.1",
	})
}

// infoHandler - 서버 정보 엔드포인트
func infoHandler(c echo.Context) error {
	return c.JSON(http.StatusOK, map[string]interface{}{
		"name":        "Go Echo Web Server",
		"version":     "1.0.1",
		"description": "GitHub Actions + AWS EC2 자동 배포 테스트",
		"endpoints": []string{
			"GET /",
			"GET /api/v1/hello",
			"GET /api/v1/info",
		},
	})
}
