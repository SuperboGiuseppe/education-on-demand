#Project name

variable "project_name" {
  type    = string
  default = "linux_on_demand"
}

variable "short_project_name" {
  type = string
  default = "lod"
}

variable "password" {
  type = string
}

variable "user_id_list" {
  type = list(string)
}

variable "member_role_id" {
  type = string
}