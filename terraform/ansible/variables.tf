variable client_id {}
variable client_secret {}
variable admin_ssh_username {}
variable admin_ssh_key {}
variable "node_location" {
type = string
}
variable "resource-prefix" {
type = string
}
variable "node_address_space" {
default = ["1.0.0.0/16"]
}
#variable for network range
variable "node_address_prefixes" {
default = ["1.0.1.0/24"]
}
#variable for Environment
variable "Environment" {
type = string
}
variable "node_count" {
type = number
}