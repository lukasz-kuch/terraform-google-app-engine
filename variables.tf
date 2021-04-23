variable "network" {
  default = "default"
  type = string
  description = "Network name"
}

variable "credentials" {
  type = string
  description = "Credential path"
}

variable "project_id" {
  type = string
  description = "Project ID of project that has App Engine created and proper Service Account configured"
}

variable "region" {
  default = "europe-west3"
  type = string
}

variable "app_source" {
  type = string
  description = "A path to the data you want to upload"
}

variable "ip_cidr_range" {
  default = "10.8.0.0/28"
  type = string
  description = "IP range must be an unused /28 CIDR range, such as 10.8.0.0/28. The VPC Connector will use IP addresses from this range. Ensure that the range does not overlap with an existing VPC network's subnets"
}

variable "app_version" {
  default = "v1"
  type = string
  description = "App version name"
}

variable "app_name" {
  type   = string
  default = "default"
  description = "The first service (module) you upload to a new application must be the 'default' service (module). Please upload a version of the 'default' service (module) before uploading a version for the 'custom' service (module)"
}
