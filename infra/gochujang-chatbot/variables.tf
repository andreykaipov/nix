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

variable "env" {
  type    = map(string)
  default = {}
}

variable "files" {
  type    = map(string)
  default = {}
}
