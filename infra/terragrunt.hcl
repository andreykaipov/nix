locals {
  git_dir = run_cmd("git", "rev-parse", "--show-toplevel")

  // path_relative_to_include
  tfstate_kv_path = "kaipov.com/infra/${path_relative_to_include()}"
}

inputs = {}

remote_state {
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  backend = "http"
  config = {
    username       = get_env("TF_BACKEND_USERNAME")
    password       = get_env("TF_BACKEND_PASSWORD")
    address        = "https://tf.kaipov.com/${local.tfstate_kv_path}"
    lock_address   = "https://tf.kaipov.com/${local.tfstate_kv_path}"
    unlock_address = "https://tf.kaipov.com/${local.tfstate_kv_path}"
  }
}

retry_max_attempts       = 3
retry_sleep_interval_sec = 10
