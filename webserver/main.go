package main

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"time"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"
	"github.com/danielgtaylor/huma/v2/humacli"
	"github.com/go-chi/chi/middleware"
	"github.com/go-chi/chi/v5"
)

type Options struct {
	Port     int    `help:"Exposed server port" short:"p" default:"8888"`
	Hostname string `help:"Domain name only" default:"localhost"`
	LogLevel string `help:"Logging level" default:"" enum:"debug,info,warn,error"`
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
		InitLogger("debug")

		port := options.Port
		endpoint := fmt.Sprintf("http://%s:%d/api/v1", options.Hostname, port)

		router := chi.NewMux()
		router.Use(middleware.Logger)
		router.Use(middleware.Timeout(10 * time.Minute))

		router.Route("/api/v1", func(r chi.Router) {
			config := huma.DefaultConfig("Demo webserver", "develop")
			config.Servers = []*huma.Server{
				{URL: endpoint},
			}
			api := humachi.New(r, config)

			huma.Get(api, "/health", healthCheckHandler)
		})

		hooks.OnStart(func() {
			slog.Info("Starting server", "port", port)
			if err := http.ListenAndServe(fmt.Sprintf(":%d", port), router); err != nil {
				slog.Error("could not start server", slog.Any("error", err))
				os.Exit(1)
			}
		})
	})
	cli.Run()
}
