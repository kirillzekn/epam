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



locals {
   
    publish_code_command = "az webapp deployment source config-zip --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_function_app.function_app.name} --src ${data.archive_file.output_path.output_path}"
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