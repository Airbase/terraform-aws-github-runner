variable "aws_region" {
  type = string
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

variable "ami_owners" {
  type = list(string)
  default = [ "null" ]
}

variable "ami_filter" {
  type = map(list(string))
  default = {
    name = [ "null" ]
  }
}

variable "pool_runner_owner" {
  type = string
  default = "null"
}

variable "volume_size" {
  type = number
  default = 10
}

variable "vpc_id" {
  type = string
  default = "null"  
}

variable "subnet_ids" {
  type = list(string)
  default = [ "null" ]
}

variable "runners_maximum_count" {
  type = number
  default = 16
}