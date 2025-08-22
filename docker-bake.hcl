target "docker-metadata-action" {}

group "default" {
  targets = ["dev"]
}

target "dev" {
  dockerfile = "Dockerfile"
  context    = "."
  target     = "development"
  tags = [
    "ghcr.io/nmdr/fastapi-demo:dev",
  ]
  args = {
    ENV = "development"
  }
}

target "prod" {
  inherits = ["docker-metadata-action"]
  dockerfile = "Dockerfile"
  context    = "."
  target     = "production"
  args = {
    ENV = "production"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}