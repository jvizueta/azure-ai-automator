module "aks" {
  source              = "./modules/aks"
  resource_group_name = var.resource_group_name
  location            = var.location
  cluster_name        = var.cluster_name
  node_count          = var.node_count
  admin_group_object_ids = var.admin_group_object_ids
  subnet_id = azurerm_subnet.aks_subnet.id
}

module "pg" {
  source              = "./modules/pg"
  resource_group_name = var.resource_group_name
  location            = var.location
  pg_server_name      = var.pg_server_name
  pg_admin_username   = var.pg_admin_username
  pg_admin_password   = var.pg_admin_password
  pg_sku_name         = var.pg_sku_name
  pg_version          = var.pg_version
  pg_storage_mb       = var.pg_storage_mb
  pg_backup_retention_days = var.pg_backup_retention_days
  pg_geo_backup_enabled    = var.pg_geo_backup_enabled
  pg_database_name         = var.pg_database_name
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  address_space       = ["10.0.0.0/8"]
  location            = var.location
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_resource_group.rg]
}


resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.240.0.0/16"]
}

