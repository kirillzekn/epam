terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.26"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {

  features {}
}

data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = "../function-app"
  output_path = "function-app.zip"
}

locals {
       publish_code_command = "az webapp deployment source config-zip --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_function_app.function_app.name} --src ${data.archive_file.output_path.output_path}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.project}-rg"
  location = var.location
}

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



resource "azurerm_function_app" "function_app" {
  
  name                       = "${var.project}-function-app"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1",
    "FUNCTIONS_WORKER_RUNTIME" = "python",
    "APPINSIGHTS_INSTRUMENTATIONKEY" = ""
  }

  os_type = "linux"
  site_config {
    linux_fx_version          = "python|3.7"
    #use_32_bit_worker_process = true
  }
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  version                    = "~3"

  # lifecycle {
  #   ignore_changes = [
  #     app_settings["WEBSITE_RUN_FROM_PACKAGE"],
  #   ]
  # }
}


resource "null_resource" "function_app_publish" {

  provisioner "local-exec" {
    command = local.publish_code_command
  }
  depends_on = [local.publish_code_command]
  triggers = {
    input_json = filemd5(data.archive_file.output_path.output_path)
    publish_code_command = local.publish_code_command
  }
}