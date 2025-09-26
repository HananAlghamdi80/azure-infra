#############################################
# Private DNS Zone for App Services
#############################################
resource "azurerm_private_dns_zone" "appsvc_dns" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "appsvc_dns_link" {
  name                  = "dns-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.appsvc_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
