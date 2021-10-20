include "root" {
  path = find_in_parent_folders()
}

inputs = {
  tf_backend_username = get_env("TF_BACKEND_USERNAME")
  tf_backend_password = get_env("TF_BACKEND_PASSWORD")
}
