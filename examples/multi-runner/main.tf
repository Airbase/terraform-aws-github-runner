locals {
  environment = var.environment != null ? var.environment : "multi-runner"
  aws_region  = "us-east-1"
}

resource "random_id" "random" {
  byte_length = 20
}
module "base" {
  source = "../base"

  prefix     = local.environment
  aws_region = local.aws_region
}

module "multi-runner" {
  source = "../../modules/multi-runner"
  multi_runner_config = {
    "linux-ubuntu" = {
      matcherConfig : {
        labelMatchers = [["self-hosted", "linux", "x64"]]
        exactMatch    = true
      }
      fifo                = true
      delay_webhook_event = 0
      redrive_build_queue = {
        enabled         = false
        maxReceiveCount = null
      }
      runner_config = {
        runner_os                      = "linux"
        runner_architecture            = "x64"
        runner_extra_labels            = ""
        runner_run_as                  = "ubuntu"
        runner_name_prefix             = "ubuntu-2204-x64_"
        key_name                       = var.key_name
        enable_ssm_on_runners          = true
        enable_ephemeral_runners       = true
        instance_types                 = ["c3.2xlarge", "c4.2xlarge", "c5.2xlarge", "c5d.2xlarge", "c5.4xlarge", "c5a.4xlarge", "c6g.4xlarge", "c6gd.4xlarge", "c7g.4xlarge"]
        instance_target_capacity_type  = var.instance_target_capacity_type
        runners_maximum_count          = var.runners_maximum_count
        scale_down_schedule_expression = "cron(* * * * ? *)"
        userdata_template              = "./templates/user-data.sh"
        ami_owners                     = var.ami_owners        # Airbase's Amazon account ID
        pool_runner_owner              = var.pool_runner_owner # Org to which the runners are added
        pool_config = [{
          size                = 1                   # size of the pool
          schedule_expression = "cron(* * * * ? *)" # cron expression to trigger the adjustment of the pool
        }]
        ami_filter      = var.ami_filter
        enable_userdata = var.enable_userdata
        block_device_mappings = [{
          # Set the block device name for Ubuntu root device
          device_name           = "/dev/sda1"
          delete_on_termination = true
          volume_type           = "gp3"
          volume_size           = var.volume_size
          encrypted             = true
          iops                  = null
          throughput            = null
          kms_key_id            = null
          snapshot_id           = null
        }]
        runner_log_files = [
          {
            log_group_name   = "syslog"
            prefix_log_group = true
            file_path        = "/var/log/syslog"
            log_stream_name  = "{instance_id}"
          },
          {
            log_group_name   = "user_data"
            prefix_log_group = true
            file_path        = "/var/log/user-data.log"
            log_stream_name  = "{instance_id}/user_data"
          },
          {
            log_group_name   = "runner"
            prefix_log_group = true
            file_path        = "/opt/actions-runner/_diag/Runner_**.log",
            log_stream_name  = "{instance_id}/runner"
          }
        ]
      }
    },
    "linux-ubuntu-8-core" = {
      matcherConfig : {
        labelMatchers = [["self-hosted-8-core"]]
        exactMatch    = true
      }
      fifo                = true
      delay_webhook_event = 0
      redrive_build_queue = {
        enabled         = false
        maxReceiveCount = null
      }
      runner_config = {
        runner_os                      = "linux"
        runner_architecture            = "x64"
        runner_extra_labels            = "self-hosted-8-core"
        runner_run_as                  = "ubuntu"
        runner_name_prefix             = "ubuntu-2204-x64_"
        key_name                       = var.key_name
        enable_ssm_on_runners          = true
        enable_ephemeral_runners       = true
        instance_types                 = ["c3.2xlarge", "c4.2xlarge", "c5.2xlarge", "c5d.2xlarge", "c5.4xlarge", "c5a.4xlarge", "c6g.4xlarge", "c6gd.4xlarge", "c7g.4xlarge"]
        instance_target_capacity_type  = var.instance_target_capacity_type
        runners_maximum_count          = var.runners_maximum_count
        scale_down_schedule_expression = "cron(* * * * ? *)"
        userdata_template              = "./templates/user-data.sh"
        ami_owners                     = var.ami_owners        # Airbase's Amazon account ID
        pool_runner_owner              = var.pool_runner_owner # Org to which the runners are added
        pool_config = [{
          size                = 1                   # size of the pool
          schedule_expression = "cron(* * * * ? *)" # cron expression to trigger the adjustment of the pool
        }]
        ami_filter      = var.ami_filter
        enable_userdata = var.enable_userdata
        block_device_mappings = [{
          # Set the block device name for Ubuntu root device
          device_name           = "/dev/sda1"
          delete_on_termination = true
          volume_type           = "gp3"
          volume_size           = var.volume_size
          encrypted             = true
          iops                  = null
          throughput            = null
          kms_key_id            = null
          snapshot_id           = null
        }]
        runner_log_files = [
          {
            log_group_name   = "syslog"
            prefix_log_group = true
            file_path        = "/var/log/syslog"
            log_stream_name  = "{instance_id}"
          },
          {
            log_group_name   = "user_data"
            prefix_log_group = true
            file_path        = "/var/log/user-data.log"
            log_stream_name  = "{instance_id}/user_data"
          },
          {
            log_group_name   = "runner"
            prefix_log_group = true
            file_path        = "/opt/actions-runner/_diag/Runner_**.log",
            log_stream_name  = "{instance_id}/runner"
          }
        ]
      }
    }
  }
  aws_region                        = local.aws_region
  vpc_id                            = var.vpc_id
  subnet_ids                        = var.subnet_ids
  runners_scale_up_lambda_timeout   = 60
  runners_scale_down_lambda_timeout = 120
  prefix                            = local.environment
  tags = {
    Project = "airbase"
  }
  github_app = {
    key_base64     = var.github_app.key_base64
    id             = var.github_app.id
    webhook_secret = random_id.random.hex
  }

  # Assuming local build lambda's to use pre build ones, uncomment the lines below and download the
  # lambda zip files lambda_download
  webhook_lambda_zip                = "../lambdas-download/webhook.zip"
  runner_binaries_syncer_lambda_zip = "../lambdas-download/runner-binaries-syncer.zip"
  runners_lambda_zip                = "../lambdas-download/runners.zip"
  enable_workflow_job_events_queue  = true
  # override delay of events in seconds

  # Enable debug logging for the lambda functions
  # log_level = "debug"

}
