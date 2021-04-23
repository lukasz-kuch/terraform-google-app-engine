provider "google" {
  credentials = file("regal-fortress-311412-1068a313626d.json")
  project     = var.project_id
  region      = var.region
}

data "google_compute_network" "network" {
  name = var.network
}

resource "google_redis_instance" "redis" {
  name           = "memory-redis"
  memory_size_gb = 1
  redis_version  = "REDIS_5_0"
  authorized_network = data.google_compute_network.network.id
}

resource "google_vpc_access_connector" "redis_connector" {
  name          = "redis-con"
  network       = data.google_compute_network.network.name
  ip_cidr_range = var.ip_cidr_range
  max_throughput = 300
}

resource "google_storage_bucket_object" "object" {
  name   = var.bucket_object_name
  bucket = var.bucket_name
  source = var.app_source
}

resource "google_app_engine_standard_app_version" "myapp_v1" {
  version_id = var.version_id
  service    = var.service_name
  runtime    = "python38"
  vpc_access_connector {
    name = google_vpc_access_connector.redis_connector.id
  }
  entrypoint {
    shell = "gunicorn -b :$PORT main:app"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${var.bucket_name}/${google_storage_bucket_object.object.name}"
    }
  }

  env_variables = {
    REDISHOST: google_redis_instance.redis.host,
    REDISPORT: 6379
  }

  depends_on = [
    google_redis_instance.redis,
    google_vpc_access_connector.redis_connector,
    google_storage_bucket_object.object
  ]
}
