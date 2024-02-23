variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "image" {
  type = string
}

variable "sha" {
  type = string
}

variable "files" {
  type        = map(string)
  default     = {}
  description = "Files will be mounted to /shared"
}

variable "env" {
  type        = map(string)
  default     = {}
  description = <<EOF
The environment variables for the container. Secrets can be set by prefacing the
value with `secret://`, followed by the contents of the secret env var.

This is done so these values are properly passed as secrets to the container.
Functionally it makes no difference. The only purpose is for Terraform to
recognize them as sensitive values and to store them as secrets in Azure.
EOF
}
