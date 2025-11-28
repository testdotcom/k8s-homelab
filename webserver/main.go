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
	Port     int    `help:"Exposed server port" short:"p" default:"8888"`
	Hostname string `help:"Domain name only" default:"localhost"`
	LogLevel string `help:"Logging level" default:"info" enum:"debug,info,warn,error"`
}

type HealthCheckResponse struct {
	Body struct {
		Status string `json:"status"`
	}
}

var REQ_TIMEOUT = 10 * time.Minute

func healthCheckHandler(_ context.Context, _ *struct{}) (*HealthCheckResponse, error) {
	resp := &HealthCheckResponse{}
	resp.Body.Status = "healthy"

	return resp, nil
}

func main() {
	cli := humacli.New(func(hooks humacli.Hooks, options *Options) {
		InitLogger("debug")

		router := chi.NewMux()
		router.Use(middleware.Logger)
		router.Use(middleware.Timeout(REQ_TIMEOUT))

		port := strconv.Itoa(options.Port)

		config := huma.DefaultConfig("Demo webserver", "develop")
		config.Servers = []*huma.Server{
			{URL: net.JoinHostPort(options.Hostname, port)},
		}
		api := humachi.New(router, config)
		huma.Get(api, "/health", healthCheckHandler)

		router.Route("/api/v1", func(r chi.Router) {
			// TODO
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
