variable "resource_group_name" {
  default = "hanan-project-rg"
}

variable "location" {
  default = "centralindia"
}

variable "sql_admin_user" {
  default = "hananadmin"
}

variable "sql_admin_password" {
  sensitive = true
}
