resource "azurerm_public_ip" "appgw_pip" {
  name                = "hanan-appgw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "hanan-waf-policy"
  resource_group_name = var.resource_group_name
  location            = var.location

  policy_settings {
    enabled            = true
    mode               = "Prevention"
    request_body_check = true
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_application_gateway" "appgw" {
  name                = "hanan-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = "httpPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgwFrontendIP"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name  = "frontendPool"
    fqdns = [azurerm_linux_web_app.frontend.default_hostname]
  }

  backend_address_pool {
    name  = "backendPool"
    fqdns = [azurerm_linux_web_app.backend.default_hostname]
  }

  backend_http_settings {
    name                  = "frontendHttpSettings"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    cookie_based_affinity = "Disabled"
  }

  backend_http_settings {
    name                  = "backendHttpSettings"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    cookie_based_affinity = "Disabled"
  }

  http_listener {
    name                           = "mainListener"
    frontend_ip_configuration_name = "appgwFrontendIP"
    frontend_port_name             = "httpPort"
    protocol                       = "Http"
  }

  url_path_map {
    name                               = "pathMap1"
    default_backend_address_pool_name  = "frontendPool"
    default_backend_http_settings_name = "frontendHttpSettings"

    path_rule {
      name                       = "backendPathRule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backendPool"
      backend_http_settings_name = "backendHttpSettings"
    }
  }

  request_routing_rule {
    name               = "rule1"
    rule_type          = "PathBasedRouting"
    http_listener_name = "mainListener"
    url_path_map_name  = "pathMap1"
    priority           = 100
  }
}
