/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "central_project_config" {
  description = "Configuration for the top-level central project."
  type = object({
    iam = optional(map(list(string)), {})
    iam_bindings = optional(map(object({
      members = list(string)
      role    = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    iam_bindings_additive = optional(map(object({
      member = string
      role   = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    iam_by_principals = optional(map(list(string)), {})
    services = optional(list(string), [
      # TODO: define default list of services
      "bigquery.googleapis.com",
      "datacatalog.googleapis.com",
      "logging.googleapis.com",
      "monitoring.googleapis.com"
    ])
    short_name = optional(string, "central-0")
  })
  nullable = false
  default  = {}
}

variable "config" {
  description = "Stage configuration used to find environment and resource ids, and to generate names."
  type = object({
    environment = string
    name        = string
    short_name  = optional(string, "dp")
  })
  default = {
    environment = "dev"
    name        = "data-platform-dev"
  }
}

variable "exposure_config" {
  description = "Data exposure configuration."
  type = object({
    tag_name = optional(string, "exposure/allow")
  })
  nullable = false
  default  = {}
  validation {
    condition = (
      var.exposure_config.tag_name != null &&
      length(regexall(
        "^[a-z][a-z0-9-]+/[a-z][a-z0-9]+", var.exposure_config.tag_name
      )) > 0
    )
    error_message = "Invalid tag name, required format is 'tag_key/tag_value'."
  }
}

variable "factories_config" {
  description = "Configuration for YAML-based factories."
  type = object({
    data_domains       = optional(string, "data/data-domains")
    projects_data_path = optional(string, "data/data-domains")
    # budgets = optional(object({
    #   billing_account       = string
    #   budgets_data_path     = optional(string, "data/budgets")
    #   notification_channels = optional(map(any), {})
    # }))
    context = optional(object({
      # TODO: add KMS keys
      folder_ids        = optional(map(string), {})
      iam_principals    = optional(map(string), {})
      tag_values        = optional(map(string), {})
      vpc_host_projects = optional(map(string), {})
    }), {})
  })
  nullable = false
  default  = {}
}

variable "location" {
  description = "Default location used when no location is specified."
  type        = string
  nullable    = false
}

variable "outputs_location" {
  description = "Enable writing provider, tfvars and CI/CD workflow files to local filesystem. Leave null to disable."
  type        = string
  default     = null
}

variable "policy_tags" {
  description = "Shared data catalog tag templates."
  type = map(object({
    display_name = optional(string)
    force_delete = optional(bool, false)
    region       = optional(string)
    fields = map(object({
      display_name = optional(string)
      description  = optional(string)
      is_required  = optional(bool, false)
      order        = optional(number)
      type = object({
        primitive_type   = optional(string)
        enum_type_values = optional(list(string))
      })
    }))
    iam = optional(map(list(string)), {})
    iam_bindings = optional(map(object({
      members = list(string)
      role    = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    iam_bindings_additive = optional(map(object({
      member = string
      role   = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
  }))
  default = {}
}

variable "stage_name" {
  description = "FAST stage name. Used to separate output files across different factories."
  type        = string
  nullable    = false
  default     = "3-data-platform-factory"
}

variable "secure_tags" {
  description = "Resource manager tags created in the central project."
  type = map(object({
    description = optional(string, "Managed by the Terraform project module.")
    iam         = optional(map(list(string)), {})
    values = optional(map(object({
      description = optional(string, "Managed by the Terraform project module.")
      iam         = optional(map(list(string)), {})
      id          = optional(string)
    })), {})
  }))
  nullable = false
  default  = {}
  validation {
    condition = alltrue([
      for k, v in var.secure_tags : v != null
    ])
    error_message = "Use an empty map instead of null as value."
  }
}
