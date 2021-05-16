#Project name

variable "project_name" {
  type    = string
  default = "linux_on_demand"
}

variable "short_project_name" {
  type = string
  default = "lod"
}

variable "project_id" {
  type = string
}

variable "user_id_list" {
  type = list(string)
}

variable "user_name_list" {
  type = list(string)
}

variable "subnet_pool_id" {
  type = string
}

variable "public_network_id" {
  type = string
}