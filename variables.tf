variable "bridge_count" {
  type    = "string"
  default = "1"
}

variable "master_count" {
  type    = "string"
  default = "1"
}

variable "bridges" {
  type = list(map(string))
}

variable "master_nodes" {
  type = list(map(string))
}

