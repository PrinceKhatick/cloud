terraform {
  required_version = ">= 0.11" 
 backend "azurerm" {
 storage_account_name = "__terraformstorageaccount__"
     container_name       = "pkcontainer"
     key                  = "terraform.tfstate"
	access_key  ="Qkr7myKS04NL3T6LkZR3ZJo8hXzSi0jQud/Z3pt2RQ2FRVHz2M7aRfybTgCZy16sOP3dVOsbXLLplTlBGUPuAg=="
  features{}
	}
}
provider "azurerm" {
  # subscription_id             = "4ce31b1f-a57c-460a-8872-01fb7723db79"
  # client_id                   = "00925964-dcc1-4621-8a9d-8001466a2753"
  # client_certificate_password = "rno4vkBspqTp4xtsDwZ0p.dkt7I0k1OZAg"
  # tenant_id                   = "0c6fce42-0449-4574-bf9c-a261c5635a02"

 # az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/4ce31b1f-a57c-460a-8872-01fb7723db79"

   features {}
}
resource "azurerm_resource_group" "rg" {
  name     = var.resource_name
  location = var.resource_location
}

resource "azurerm_app_service_plan" "app_plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "web_app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}