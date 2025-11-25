target "docker-metadata-action" {}

target "build" {
  inherits = ["docker-metadata-action"]
  context = "./"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64"]
  tags = ["ghcr.io/testdotcom/webserver:latest"]
  output = ["type=docker"]
}
