# ============================================================
# Lab 3 - Infraestructura con Terraform
# Arquitectura: Landing Zone + Well-Architected (Azure for Students)
# ============================================================

# ------------------------------------------------------------
# Resource Group
# ------------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ------------------------------------------------------------
# Virtual Network + Subnets
# ------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes

  # Delegation necesaria para App Service VNet Integration (snet-app)
  dynamic "delegation" {
    for_each = each.key == "app" ? [1] : []
    content {
      name = "delegation-app-service"
      service_delegation {
        name = "Microsoft.Web/serverFarms"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/action"
        ]
      }
    }
  }
}

# ------------------------------------------------------------
# Network Security Groups (básicos)
# ------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  for_each = {
    app     = "nsg-app"
    db      = "nsg-db"
    vm      = "nsg-vm"
    pe      = "nsg-endpoints"
    bastion = "nsg-bastion"
  }

  name                = each.value
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# ============================================================
# Reglas OBLIGATORIAS para Azure Bastion (NSG)
# ============================================================

# ---- Inbound ----
resource "azurerm_network_security_rule" "bastion_allow_https_inbound" {
  name                        = "AllowHttpsInbound"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg["bastion"].name
}

resource "azurerm_network_security_rule" "bastion_allow_gateway_manager" {
  name                        = "AllowGatewayManagerInbound"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg["bastion"].name
}

resource "azurerm_network_security_rule" "bastion_allow_load_balancer" {
  name                        = "AllowAzureLoadBalancerInbound"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg["bastion"].name
}

resource "azurerm_network_security_rule" "bastion_allow_host_communication_inbound" {
  name                        = "AllowBastionHostCommunication"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["8080", "5701"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg["bastion"].name
}

# ---- Outbound ----
resource "azurerm_network_security_rule" "bastion_allow_ssh_rdp_outbound" {
  name                        = "AllowSshRdpOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "3389"]
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg["bastion"].name
}

resource "azurerm_network_security_rule" "bastion_allow_azure_cloud_outbound" {
  name                        = "AllowAzureCloudOutbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg["bastion"].name
}

resource "azurerm_network_security_rule" "bastion_allow_host_communication_outbound" {
  name                        = "AllowBastionHostCommunicationOutbound"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["8080", "5701"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg["bastion"].name
}

resource "azurerm_network_security_rule" "bastion_allow_get_session" {
  name                        = "AllowGetSessionInformation"
  priority                    = 130
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg["bastion"].name
}

# ------------------------------------------------------------
# Azure Bastion
# ------------------------------------------------------------
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-terraformjdg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-utvt-integradora-dev-mxc-001-terraformjdg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnets["bastion"].id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}

# ------------------------------------------------------------
# Virtual Machine Linux (Worker)
# ------------------------------------------------------------
resource "azurerm_network_interface" "vm" {
  name                = "nic-vm-worker-terraformjdg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets["vm"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "worker" {
  name                            = "vm-linux-worker-terraformjdg"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.vm.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ------------------------------------------------------------
# App Service Plan + Linux Web App + VNet Integration
# ------------------------------------------------------------
resource "azurerm_service_plan" "app" {
  name                = "asp-utvt-integradora-dev-mxc-001-terraformjdg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = var.tags
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-utvt-integradora-dev-mxc-001-terraformjdg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app.id
  https_only          = true

  site_config {
    always_on = false
    application_stack {
      node_version = "18-lts"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# VNet Integration (Regional)
resource "azurerm_app_service_virtual_network_swift_connection" "app" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = azurerm_subnet.subnets["app"].id
}

# ------------------------------------------------------------
# Storage Account (Blob)
# ------------------------------------------------------------
resource "azurerm_storage_account" "blob" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true
  min_tls_version                 = "TLS1_2"

  blob_properties {
    versioning_enabled = false
  }

  tags = var.tags
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.blob.name
  container_access_type = "private"
}

# ------------------------------------------------------------
# PostgreSQL Flexible Server
# ------------------------------------------------------------
resource "azurerm_postgresql_flexible_server" "psql" {
  name                   = "psql-utvt-integradora-dev-mxc-001-terraformjdg"
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  version                = var.psql_version
  administrator_login    = var.psql_admin_login
  administrator_password = var.psql_admin_password
  sku_name               = var.psql_sku
  storage_mb             = var.psql_storage_mb
  zone                   = "1"

  public_network_access_enabled = false

  tags = var.tags

  lifecycle {
    ignore_changes = [
      zone,
      high_availability,
    ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "integradora" {
  name      = "integradora"
  server_id = azurerm_postgresql_flexible_server.psql.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# ------------------------------------------------------------
# Private DNS Zones
# ------------------------------------------------------------
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "link-postgres-vnet"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob-vnet"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

# ------------------------------------------------------------
# Private Endpoints
# ------------------------------------------------------------
resource "azurerm_private_endpoint" "psql" {
  name                = "pep-utvt-integradora-db-dev-mxc-001-terraformjdg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnets["pe"].id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-psql"
    private_connection_resource_id = azurerm_postgresql_flexible_server.psql.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }

  private_dns_zone_group {
    name                 = "dns-psql"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres.id]
  }
}

resource "azurerm_private_endpoint" "blob" {
  name                = "pep-utvt-integradora-blob-dev-mxc-001-terraformjdg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnets["pe"].id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-blob"
    private_connection_resource_id = azurerm_storage_account.blob.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "dns-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}