terraform {
  backend "azurerm" {
  storage_account_name = "epamtfbackendstorage"
  container_name = "terraform"
  key = "terraform.tfstate"

  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.26"
    }
  }
}
###############################
# Configure the Azure provider
provider "azurerm" {
  features {}
}
###############################
# Data
data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = "./function-app"
  output_path = "./function-app.zip"
}
###############################
# Locals
# locals {
#        publish_code_command = "az webapp deployment source config-zip --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_function_app.function_app.name} --src ${data.archive_file.file_function_app.output_path}"
# }
###############################
# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.project}-rg"
  location = var.location
}
###############################
# App service
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.project}-app-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  kind                = "FunctionApp"
  reserved = true # this has to be set to true for Linux. Not related to the Premium Plan
 
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}
###############################
# Function
resource "azurerm_function_app" "function_app" {
  name                       = "${var.project}-function-app"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "https://${azurerm_storage_account.storage_account.name}.blob.core.windows.net/${azurerm_storage_container.storage_container.name}/${azurerm_storage_blob.storage_blob.name}${data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas}",
    "FUNCTIONS_WORKER_RUNTIME" = "python",
    "APPINSIGHTS_INSTRUMENTATIONKEY" = ""
  }

  os_type = "linux"
  site_config {
    linux_fx_version          = "python|3.7"
  }
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~3"

}
###############################
# Null resource for Function
# resource "null_resource" "function_app_publish" {
#   provisioner "local-exec" {
#     command = local.publish_code_command
#   }
#   depends_on = [local.publish_code_command]
#   triggers = {
#     input_json = filemd5(data.archive_file.file_function_app.output_path)
#     publish_code_command = local.publish_code_command
#   }
# }
###############################
# SQL server 
resource "azurerm_mysql_server" "mysql-server" {
  name = "${var.project}-mysql-server"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
 
  administrator_login = var.mysql-admin-login
  administrator_login_password = var.mysql-admin-password
 
  sku_name = var.mysql-sku-name
  version = var.mysql-version
 
  storage_mb = var.mysql-storage
  auto_grow_enabled = true
  
  backup_retention_days = 7
  geo_redundant_backup_enabled = false
  public_network_access_enabled = true
  ssl_enforcement_enabled = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}
###############################
# SQL DB
resource "azurerm_mysql_database" "mysql-db" {
  name                = "${var.project}_mysql_db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
###############################
# Static Web App
#resource "azurerm_static_site" "my_webapp" {
#  name                = "${var.project}-static-webapp"
#  resource_group_name = azurerm_resource_group.rg.name
#  location            = azurerm_resource_group.rg.location
#}

###############################
# Storage account
resource "azurerm_storage_account" "storage_account" {
  name = "${var.project}storage"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_storage_container" "storage_container" {
  name                  = "function-scm"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}
resource "azurerm_storage_blob" "storage_blob" {
  name = "${filesha256(data.archive_file.file_function_app.output_path)}.zip"
  storage_account_name = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container.name
  type = "Block"
  source = data.archive_file.file_function_app.output_path
}
data "azurerm_storage_account_blob_container_sas" "storage_account_blob_container_sas" {
  connection_string = azurerm_storage_account.storage_account.primary_connection_string
  container_name    = azurerm_storage_container.storage_container.name

  start = "2021-01-01T00:00:00Z"
  expiry = "2022-04-04T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}
