package main

import (
	"context"
	"log/slog"
	"net"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"
	"github.com/danielgtaylor/huma/v2/humacli"
	"github.com/go-chi/chi/middleware"
	"github.com/go-chi/chi/v5"
)

type Options struct {
	Port       int    `help:"Exposed server port" short:"p" default:"8888"`
	Hostname   string `help:"Domain name only" default:"localhost"`
	LogLevel   string `help:"Logging level" default:"info" enum:"debug,info,warn,error"`
	ReqTimeout int64  `help:"Request timeout (in minutes)" default:"10"`
}

type HealthCheckResponse struct {
	Body struct {
		Status string `json:"status"`
	}
}

func healthCheckHandler(_ context.Context, _ *struct{}) (*HealthCheckResponse, error) {
	resp := &HealthCheckResponse{}
	resp.Body.Status = "healthy"

	return resp, nil
}

func main() {
	cli := humacli.New(func(hooks humacli.Hooks, options *Options) {
		InitLogger(options.LogLevel)

		router := chi.NewMux()
		router.Use(middleware.Logger)

		timeout := time.Duration(options.ReqTimeout) * time.Minute
		router.Use(middleware.Timeout(timeout))

		port := strconv.Itoa(options.Port)

		config := huma.DefaultConfig("Demo webserver", "develop")
		config.Servers = []*huma.Server{
			{URL: net.JoinHostPort(options.Hostname, port)},
		}
		api := humachi.New(router, config)
		huma.Get(api, "/health", healthCheckHandler)

		router.Route("/api/v1", func(r chi.Router) {
			// YOUR ENDPOINTS HERE
		})

		hooks.OnStart(func() {
			slog.Info("Starting server", "port", port)

			if err := http.ListenAndServe(":"+port, router); err != nil {
				slog.Error("could not start server", slog.Any("error", err))
				os.Exit(1)
			}
		})
	})
	cli.Run()
}
