output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "frontend_app_url" {
  value = "https://${azurerm_linux_web_app.frontend.default_hostname}"
}

output "backend_app_url" {
  value = "https://${azurerm_linux_web_app.backend.default_hostname}"
}

output "sql_server" {
  value = azurerm_mssql_server.sql.fully_qualified_domain_name
}

output "app_gateway_public_ip" {
  value = azurerm_public_ip.appgw_pip.ip_address
}

output "app_gateway_url" {
  value = "http://${azurerm_public_ip.appgw_pip.ip_address}"
}
