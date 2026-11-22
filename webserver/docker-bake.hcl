target "docker-metadata-action" {
  tags = ["ghcr.io/testdotcom/webserver:latest"]
}

target "build" {
  inherits = ["docker-metadata-action"]
  context = "./"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64"]
  output = ["type=docker"]
}
