provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
}

locals {
  app_dns = var.app_name != "default" ? "${var.app_name}-dot-${var.project_id}.ey.r.appspot.com" : "${var.project_id}.ey.r.appspot.com"
}

data"google_compute_network" "network" {
  name = var.network
}

resource "google_redis_instance" "redis" {
  name               = "app-redis"
  memory_size_gb     = 1
  redis_version      = "REDIS_5_0"
  authorized_network = data.google_compute_network.network.id
}

resource "google_vpc_access_connector" "connector" {
  name            = "app-con"
  network         = data.google_compute_network.network.name
  ip_cidr_range   = var.ip_cidr_range
  max_throughput  = 300
}

resource "google_storage_bucket" "bucket" {
  name   = lower("${var.app_name}-${var.project_id}")
}

resource "google_storage_bucket_object" "object" {
  name   = "${var.app_name}-object"
  bucket = google_storage_bucket.bucket.name
  source = var.app_source

  depends_on = [
    google_storage_bucket.bucket
  ]
}

resource "google_app_engine_standard_app_version" "my_app" {
  version_id = var.app_version
  service    = var.app_name
  runtime    = "python38"
  vpc_access_connector {
    name = google_vpc_access_connector.connector.id
  }
  entrypoint {
    shell = "gunicorn -b :$PORT main:app"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.bucket.name}/${google_storage_bucket_object.object.name}"
    }
  }

  env_variables = {
    REDISHOST: google_redis_instance.redis.host,
    REDISPORT: 6379
  }

  delete_service_on_destroy = true

  depends_on = [
    google_redis_instance.redis,
    google_vpc_access_connector.connector,
    google_storage_bucket.bucket
  ]
}
