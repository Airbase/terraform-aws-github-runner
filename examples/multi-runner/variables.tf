variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = null
}

variable "github_app" {
  description = "GitHub for API usages."

  type = object({
    id         = string
    key_base64 = string
  })
}

variable "key_name" {
  type    = string
  default = null
}

variable "ami_owners" {
  type    = list(string)
  default = ["null"]
}

variable "ami_filter" {
  type = map(list(string))
  default = {
    name = ["null"]
  }
}

variable "enable_userdata" {
  type    = bool
  default = true
}

variable "pool_runner_owner" {
  type    = string
  default = "null"
}

variable "volume_size" {
  type    = number
  default = 10
}

variable "vpc_id" {
  type    = string
  default = "null"
}

variable "subnet_ids" {
  type    = list(string)
  default = ["null"]
}

variable "runners_maximum_count" {
  type    = number
  default = 16
}

variable "minimum_running_time_in_minutes" {
  type    = number
  default = 60
}

variable "instance_target_capacity_type" {
  description = "Default lifecycle used for runner instances, can be either `spot` or `on-demand`."
  type        = string
  default     = "spot"
  validation {
    condition     = contains(["spot", "on-demand"], var.instance_target_capacity_type)
    error_message = "The instance target capacity should be either spot or on-demand."
  }
}
