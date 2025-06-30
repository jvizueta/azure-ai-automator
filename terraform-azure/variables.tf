# Common Config
variable "resource_group_name" {}
variable "location" {}

# AKS
variable "cluster_name" {}
variable "node_count" {
  default = 3
}
variable "admin_group_object_ids" {
  type = list(string)
}

# PostgreSQL settings
variable "pg_server_name" {
  type        = string
  description = "Name for PostgreSQL server"
}
variable "pg_database_name" {
  type        = string
  description = "Name of the database to create"
}
variable "pg_admin_username" {
  type        = string
  default     = "poadmin"
  description = "Administrator username for PostgreSQL"
}
variable "pg_admin_password" {
  type      = string
  description = "Administrator password for PostgreSQL"
  sensitive = true
}
variable "pg_sku_name" {
  type        = string
  default     = "GP_Gen5_2"
  description = "SKU name for PostgreSQL server"
}
variable "pg_version" {
  type        = string
  default     = "12"
  description = "PostgreSQL version"
}
variable "pg_storage_mb" {
  type        = number
  default     = 5120
  description = "Storage size in MB"
}
variable "pg_backup_retention_days" {
  type        = number
  default     = 7
  description = "Backup retention in days"
}
variable "pg_geo_backup_enabled" {
  type        = bool
  default     = false
  description = "Enable geo-redundant backups"
}