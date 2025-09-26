#################################
# Public IP for Application Gateway
#################################
resource "azurerm_public_ip" "appgw_pip" {
  name                = "hanan-appgw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#################################
# Web Application Firewall Policy
#################################
resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "hanan-waf-policy"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

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

#################################
# Application Gateway
#################################
resource "azurerm_application_gateway" "appgw" {
  name                = "hanan-appgw"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = "httpPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgwFrontendIP"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  #################################
  # Health Probes
  #################################
  probe {
    name                = "frontend-probe"
    protocol            = "Http"
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399"]
    }
  }

  probe {
    name                = "backend-probe"
    protocol            = "Http"          # ✅ رجعناه لـ HTTP
    path                = "/health"       # ✅ صفحة الـ health
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399"]
    }
  }

  #################################
  # Backend Pools
  #################################
  backend_address_pool {
    name  = "frontendPool"
    fqdns = [azurerm_linux_web_app.frontend.default_hostname]
  }

  backend_address_pool {
    name  = "backendPool"
    fqdns = [azurerm_linux_web_app.backend.default_hostname]
  }

  #################################
  # HTTP Settings
  #################################
  backend_http_settings {
    name                  = "frontendHttpSettings"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    cookie_based_affinity = "Disabled"
    host_name             = azurerm_linux_web_app.frontend.default_hostname
    probe_name            = "frontend-probe"
  }

  backend_http_settings {
    name                  = "backendHttpSettings"
    port                  = 8181            # ✅ رجعناه لـ 8181
    protocol              = "Http"          # ✅ رجعناه لـ HTTP
    request_timeout       = 30
    cookie_based_affinity = "Disabled"
    host_name             = azurerm_linux_web_app.backend.default_hostname
    probe_name            = "backend-probe"
  }

  #################################
  # Listener
  #################################
  http_listener {
    name                           = "mainListener"
    frontend_ip_configuration_name = "appgwFrontendIP"
    frontend_port_name             = "httpPort"
    protocol                       = "Http"
  }

  #################################
  # Path-based Routing
  #################################
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
