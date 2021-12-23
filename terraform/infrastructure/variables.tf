variable client_id {}
variable client_secret {}
#variable archive_file { }
variable storage_account_access_key {
  type = string
}
variable storage_account_name {
  type = string
}


variable project {
  type = string
  default = "zekn"
  
}
variable location {
    default = "westeurope"
}
variable "mysql-admin-login" {
  type = string
  description = "Login to authenticate to MySQL Server"
}
variable "mysql-admin-password" {
  type = string
  description = "Password to authenticate to MySQL Server"
}
# variable "mysql-version" {
#   type = string
#   description = "MySQL Server version to deploy"
#   default = "8.0"
# }
# variable "mysql-sku-name" {
#   type = string
#   description = "MySQL SKU Name"
#   default = "8.0"
# }
# variable "mysql-storage" {
#   type = string
#   description = "MySQL Storage in MB"
#   default = "5120"
# }


