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
