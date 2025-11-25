target "docker-metadata-action" {}

target "build" {
  inherits = ["docker-metadata-action"]
  context = "./"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64"]
  tags = ["testdotcom/webserver:latest"]
  output = ["type=docker"]
}
