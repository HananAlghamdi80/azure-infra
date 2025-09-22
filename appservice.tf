resource "azurerm_service_plan" "plan" {
  name                = "hanan-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "frontend" {
  name                = "hanan-frontend-app-1234"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
}

resource "azurerm_linux_web_app" "backend" {
  name                = "hanan-backend-app-1234"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    DB_HOST                             = azurerm_mssql_server.sql.fully_qualified_domain_name
    DB_NAME                             = azurerm_mssql_database.sqldb.name
    DB_USER                             = var.sql_admin_user
    DB_PASS                             = var.sql_admin_password
  }
}
