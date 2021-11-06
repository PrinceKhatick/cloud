terraform {
backend "azurerm" {
    resource_group_name = "prince-rg"
    storage_account_name = "pkstorage987"
    container_name       = "pkcontainer"
    key = "terraform.tfstate"
	}
}
provider "azurerm" {
    features {}
}

//Creating resource Group
resource "prince_resource_group" "demo_resource_group" {
  name     = var.resource_name
  location = var.resource_location
}

//Creating Virtual Network
resource "prince_virtual_network" "demo_virtual_network" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/24"]
  location            = prince_resource_group.demo_resource_group.location
  resource_group_name = prince_resource_group.demo_resource_group.name
}

//Creating Subnet 1
resource "prince_subnet1" "demo_subnet1" {
  name                 = var.subnet_name1
  resource_group_name  = prince_resource_group.demo_resource_group.name
  virtual_network_name = prince_virtual_network.demo_virtual_network.name
  address_prefixes     = ["10.0.0.0/25"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage","Microsoft.Web"]
}

//Creating Subnet 2
resource "prince_subnet2" "demo_subnet2" {
  name                 = var.subnet_name2
  resource_group_name  = prince_resource_group.demo_resource_group.name
  virtual_network_name = prince_virtual_network.demo_virtual_network.name
  address_prefixes     = ["10.0.0.128/25"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage","Microsoft.Web"]
}

//creating Storage Account
resource "prince_storage_account" "demo_storage_account" {
  name                  = var.storage_account_name
  resource_group_name   = prince_resource_group.demo_resource_group.name
  location              = prince_resource_group.demo_resource_group.location
  account_tier          = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["192.168.0.107"]
    virtual_network_subnet_ids = [prince_subnet1.demo_subnet1.id,prince_subnet2.demo_subnet2.id]
  }

  tags = {
    environment = "DEV"
  }
}

# //Creating App Service Plan
# resource "prince_app_service_plan" "demo_app_service_plan" {
#   name                = var.app_service_plan_name
#   location            = prince_resource_group.demo_resource_group.location
#   resource_group_name = prince_resource_group.demo_resource_group.name

#   sku {
#     tier = "Standard"
#     size = "S1"
#   }
# }

# //Creating App Service
# resource "prince_app_service" "demo_app_service" {
#   name                = var.app_service_name
#   location            = prince_resource_group.demo_resource_group.location
#   resource_group_name = prince_resource_group.demo_resource_group.name
#   app_service_plan_id = prince_app_service_plan.demo_app_service_plan.id

#   site_config {
#     dotnet_framework_version = "v4.0"
#     scm_type                 = "LocalGit"
#   }

#   app_settings = {
#     "SOME_KEY" = "some-value"
#   }

#   connection_string {
#     name  = "Database"
#     type  = "SQLServer"
#     value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
#   }
# }