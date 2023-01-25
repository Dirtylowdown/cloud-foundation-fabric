variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "region" {
  description = "Cloud region where resource will be deployed"
  type        = string
  default     = "europe-west1"
}

variable "run_svc_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "hello"
}

variable "image" {
  description = "Container image to deploy"
  type        = string
}

variable "glb_create" {
  description = "Create a Global Load Balancer in front of the Cloud Run service"
  type        = bool
  default     = false
}
