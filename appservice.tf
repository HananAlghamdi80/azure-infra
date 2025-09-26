#############################################
# App Service Plan
#############################################
resource "azurerm_service_plan" "plan" {
  name                = "hanan-asp"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "B1"
}

#############################################
# Frontend Web App (Docker)
#############################################
resource "azurerm_linux_web_app" "frontend" {
  name                = "hanan-frontend-app-1234"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    # تفعيل تشغيل الحاوية
    container_registry_use_managed_identity = false
  }

  app_settings = {
    # تشغيل الـ Docker Image
    DOCKER_CUSTOM_IMAGE_NAME            = "gajicfilip/fg_ecommerce_frontend:2.0"

    # تعطيل التخزين المحلي
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"

    # منفذ التطبيق داخل الحاوية
    WEBSITES_PORT                       = "3000"
  }
}

#############################################
# Backend Web App (Docker)
#############################################
resource "azurerm_linux_web_app" "backend" {
  name                = "hanan-backend-app-1234"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    container_registry_use_managed_identity = false
  }

  app_settings = {
    DOCKER_CUSTOM_IMAGE_NAME            = "gajicfilip/fg_ecommerce_backend:2.0"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "8181"

    # إعدادات قاعدة البيانات
    DB_HOST = azurerm_mssql_server.sql.fully_qualified_domain_name
    DB_NAME = azurerm_mssql_database.sqldb.name
    DB_USER = var.sql_admin_user
    DB_PASS = var.sql_admin_password
  }
}
