# syntax=docker/dockerfile:1
FROM golang:1.26-alpine AS builder

WORKDIR /app

COPY . ./
RUN --mount=type=cache,target=/go/pkg/mod \
    # Production optimizations
    CGO_ENABLED=0 go build -ldflags='-s -w' -o /webserver .

FROM scratch

WORKDIR /app
COPY --from=builder /webserver ./webserver

EXPOSE 3000

ENTRYPOINT ["./webserver"]
