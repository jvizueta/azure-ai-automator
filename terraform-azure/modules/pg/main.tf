resource "random_password" "pg_password" {
  length  = 16
  special = true
}

resource "azurerm_postgresql_server" "pg" {
  name                         = var.pg_server_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  sku_name                     = var.pg_sku_name
  version                      = var.pg_version
  administrator_login          = var.pg_admin_username
  administrator_login_password = var.pg_admin_password
  storage_mb                   = var.pg_storage_mb
  backup_retention_days        = var.pg_backup_retention_days
  geo_redundant_backup_enabled = var.pg_geo_backup_enabled
  ssl_enforcement_enabled      = true
  auto_grow_enabled            = true
  public_network_access_enabled = true
}

resource "azurerm_postgresql_database" "db" {
  name                = var.pg_database_name
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.pg.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Private endpoint for Postgres
resource "azurerm_private_endpoint" "pg_pe" {
  name                = "pg-private-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = var.pg_subnet_id

  private_service_connection {
    name                           = "pg-psc"
    private_connection_resource_id = azurerm_postgresql_server.pg.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }
}