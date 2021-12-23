resource "azurerm_static_site" "my_webapp" {
  name                = "${var.project}-static-webapp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}