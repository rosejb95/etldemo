provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "etl" {
  name     = "etl"
  location = "eastus"
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "benton-k8-cluster"
  location            = azurerm_resource_group.etl.location
  resource_group_name = azurerm_resource_group.etl.name
  dns_prefix          = "benton-k8-cluster-dns"
  kubernetes_version  = "1.23.12"
  http_application_routing_enabled = true

  default_node_pool {
    name       = "agentpool"
    node_count = 1
    vm_size    = "Standard_B4ms"
    enable_auto_scaling = false
    zones      = ["1", "2",]
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_server" "rosejbdev" {
  name                         = "rosejbdev"
  resource_group_name          = azurerm_resource_group.etl.name
  location                     = azurerm_resource_group.etl.location
  version                      = "12.0"
  administrator_login          = var.db_username
  administrator_login_password = var.db_password
}

resource "azurerm_mssql_database" "bdbdb" {
  name           = "bdbdb"
  server_id      = azurerm_mssql_server.rosejbdev.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 250
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false
}

resource "azurerm_container_registry" "bdbcr" {
  name                = "bdbcr"
  resource_group_name = azurerm_resource_group.etl.name
  location            = azurerm_resource_group.etl.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_storage_account" "oculusdemo" {
  name                     = "oculusdemo"
  resource_group_name      = azurerm_resource_group.etl.name
  location                 = azurerm_resource_group.etl.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  nfsv3_enabled            = true
  sftp_enabled             = true
  cross_tenant_replication_enabled = false
  default_to_oauth_authentication  = true
}



## Will attempt to fix this later. For some reason it's impossible to find the id of an existing fileshare.
# resource "azurerm_storage_share" "etlshare" {
#   name                 = "etlshare"
#   storage_account_name = azurerm_storage_account.oculusdemo.name
#   quota                = 5120
# }