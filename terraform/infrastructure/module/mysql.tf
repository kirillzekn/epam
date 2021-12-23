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

resource "azurerm_mysql_database" "mysql-db" {
  name                = "${var.project}-mysql-db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# resource "azurerm_mysql_firewall_rule" "mysql-fw-rule" {
#   name                = "MySQL Office Access"
#   resource_group_name = azurerm_resource_group.rg.name
#   server_name         = azurerm_mysql_server.mysql-server.name
#   start_ip_address    = "210.170.94.100"
#   end_ip_address      = "210.170.94.110"
# }