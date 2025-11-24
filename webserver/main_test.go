package main

import (
	"strings"
	"testing"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/humatest"
)

func TestHealthEndpoint(t *testing.T) {
	_, api := humatest.New(t)
	huma.Get(api, "/health", healthCheckHandler)

	resp := api.Get("/health")
	if !strings.Contains(resp.Body.String(), "healthy") {
		t.Fatalf("unexpected response: %s", resp.Body.String())
	}
}
