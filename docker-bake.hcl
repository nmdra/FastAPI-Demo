variable "TAG" {
  default = "latest"
}

variable "registry" {
    default = "ghcr.io/nmdra"
}

group "default" {
  targets = ["dev", "prod"]
}

target "dev" {
  dockerfile = "Dockerfile.dev"
  context    = "."
  tags = [
    "${registry}/fastapi-demo:dev",
    "${registry}/fastapi-demo:${TAG}-dev"
  ]
  args = {
    ENV = "development"
  }
}

target "prod" {
  dockerfile = "Dockerfile.prod"
  context    = "."
  tags = [
    "${registry}/fastapi-demo:${TAG}"
  ]
  args = {
    ENV = "production"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  labels = {
    "org.opencontainers.image.title"       = "FastAPI Demo"
    "org.opencontainers.image.created"     = "${timestamp()}"
    "org.opencontainers.image.version"     = "${TAG}"
    "org.opencontainers.image.source"      = "https://github.com/nmdra/fastapi-demo"
    "org.opencontainers.image.licenses"    = "MIT"
    "org.opencontainers.image.description" = "Demo FastAPI app using Docker Bake"
  }
}