variable "prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
  default     = "utvt-integradora"
}

variable "environment" {
  description = "Ambiente (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "eastus" # Cambia según tu preferencia / disponibilidad Students
}

variable "resource_group_name" {
  description = "Nombre del Resource Group"
  type        = string
  default     = "rg-utvt-integradora-dev-mxc-001-terraformjdg"
}

# ---------------- Redes ----------------
variable "vnet_name" {
  type    = string
  default = "vnet-utvt-integradora-dev-mxc-001-terraformjdg"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Definición de subredes"
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  default = {
    app = {
      name             = "snet-utvt-integradora-app-dev-mxc-001-terraformjdg"
      address_prefixes = ["10.0.1.0/24"]
    }
    db = {
      name             = "snet-utvt-integradora-db-dev-mxc-001-terraformjdg"
      address_prefixes = ["10.0.2.0/24"]
    }
    vm = {
      name             = "snet-utvt-integradora-vm-dev-mxc-001-terraformjdg"
      address_prefixes = ["10.0.3.0/24"]
    }
    pe = {
      name             = "snet-utvt-integradora-pe-dev-mxc-001-terraformjdg"
      address_prefixes = ["10.0.4.0/24"]
    }
    bastion = {
      name             = "AzureBastionSubnet" # Nombre OBLIGATORIO para Bastion
      address_prefixes = ["10.0.5.0/24"]
    }
  }
}

# ---------------- Tags ----------------
variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "ProyectoIntegradora"
    ManagedBy   = "Terraform"
    Owner       = "Jaime"
    Lab         = "Lab3-Terraform"
  }
}

# ---------------- VM ----------------
variable "vm_size" {
  type    = string
  default = "Standard_B2ats_v2" # Según diagrama
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = "P@ssw0rd1234!" # ¡Cámbialo! Solo para lab
}

# ---------------- PostgreSQL ----------------
variable "psql_sku" {
  type    = string
  default = "B_Standard_B1ms" # Burstable B1ms del diagrama
}

variable "psql_storage_mb" {
  type    = number
  default = 32768
}

variable "psql_version" {
  type    = string
  default = "16"
}

variable "psql_admin_login" {
  type    = string
  default = "psqladmin"
}

variable "psql_admin_password" {
  type      = string
  sensitive = true
  default   = "P@ssw0rd1234!" # ¡Cámbialo!
}

# ---------------- Storage ----------------
variable "storage_account_name" {
  # Debe ser globalmente único, solo minúsculas y números
  type    = string
  default = "stutvtintdevmxc001jdg" # Ajustado para unicidad (sin guiones)
}

# ---------------- App Service ----------------
variable "app_service_sku" {
  type    = string
  default = "B1" # Basic B1 del diagrama
}
