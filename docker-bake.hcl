target "docker-metadata-action" {}

group "default" {
  targets = ["dev"]
}

target "dev" {
  dockerfile = "Dockerfile.dev"
  context    = "."
  tags = [
    "ghcr.io/nmdr/fastapi-demo:dev",
  ]
  args = {
    ENV = "development"
  }
}

target "prod" {
  inherits = ["docker-metadata-action"]
  dockerfile = "Dockerfile.prod"
  context    = "."
  args = {
    ENV = "production"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}