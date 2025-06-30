output "postgres_fqdn" {
  description = "Fully qualified domain name of PostgreSQL server"
  value       = azurerm_postgresql_server.pg.fully_qualified_domain_name
}