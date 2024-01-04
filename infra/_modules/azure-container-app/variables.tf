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
value with `secret://`, followed by the name of the secret to lookup in
`var.secrets`.

This is done so these values are properly passed as secrets to the container.
Functionally it makes no difference. The only purpose is for Terraform to
recognize them as sensitive values and to store them as secrets in Azure,

If you don't care, you can just pass the secrets directly in the environment.
I can't tell you what to do.
EOF
}

variable "secrets" {
  type        = map(string)
  default     = {}
  description = "For lookup in `var.env`. These will still be stored in the tfstate."
}
