# Terraform App-Engine Module

For App Engine Deployment in GCP

This Terraform module deploys App-Engine with following resources:

- google_app_engine_standard_app_version.my_app 
- google_redis_instance.redis 
- google_storage_bucket.bucket 
- google_storage_bucket_object.object 
- google_vpc_access_connector.connector 

## Usage

```hcl
module "app-engine" {
  source  = "app.terraform.io/private-dev/app-engine/google"
  version = "1.0.0"
  
  app_source          = "..."
  project_id          = "..."
  app_name            = "..."
  credentials         = "..."
  # insert optional variables here
}
```
