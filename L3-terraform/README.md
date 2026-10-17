# Lab 3 – Infraestructura como Código con Terraform

Despliegue de la arquitectura de referencia **Azure for Students (Landing Zone + Well-Architected)** usando Terraform.

## Diagrama

La infraestructura implementa:

- Virtual Network `10.0.0.0/16` con 5 subredes
- Azure Bastion
- VM Linux (worker) B2ats_v2
- App Service Linux B1 + VNet Integration
- PostgreSQL Flexible Server (Burstable B1ms) – acceso público deshabilitado
- Storage Account (Blob) – acceso público deshabilitado
- Private Endpoints + Private DNS Zones
- Network Security Groups

## Estructura del proyecto

```
L3-terraform/
├── versions.tf          # Versiones de Terraform y providers
├── providers.tf         # Configuración del provider azurerm
├── variables.tf         # Variables de entrada
├── main.tf              # Todos los recursos
├── outputs.tf           # Valores de salida
├── terraform.tfvars.example
└── README.md
```

## Requisitos previos

1. [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
2. [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
3. Suscripción Azure for Students (o cualquier suscripción con permisos de Contributor)
4. Autenticación:

```bash
az login
az account set --subscription "<ID o nombre de tu suscripción>"
```

## Cómo desplegar

```bash
# 1. Ir a la carpeta del proyecto
cd L3-terraform

# 2. Crear archivo de variables (copia el ejemplo)
cp terraform.tfvars.example terraform.tfvars
# Edita terraform.tfvars y cambia las contraseñas y el storage_account_name

# 3. Inicializar
terraform init

# 4. Revisar el plan
terraform plan -out=tfplan

# 5. Aplicar
terraform apply tfplan

# 6. Ver outputs
terraform output
```

## Comandos útiles

```bash
# Ver estado
terraform show

# Destruir todo (¡cuidado!)
terraform destroy

# Formatear código
terraform fmt -recursive

# Validar
terraform validate
```

## Notas importantes

- **Azure Bastion** genera costo incluso cuando no se usa. Destrúyelo cuando termines la práctica.
- El nombre del **Storage Account** debe ser único a nivel mundial.
- La subred de Bastion **debe** llamarse exactamente `AzureBastionSubnet`.
- PostgreSQL Flexible Server y Storage tienen `public_network_access_enabled = false`.
- Las contraseñas por defecto son solo para laboratorio. **Cámbialas**.

## Nombres de recursos (según Excel del Lab)

| Recurso                    | Nombre                                                      |
|---------------------------|-------------------------------------------------------------|
| Resource Group            | rg-utvt-integradora-dev-mxc-001-terraformjdg                |
| VNet                      | vnet-utvt-integradora-dev-mxc-001-terraformjdg              |
| Subnet App                | snet-utvt-integradora-app-dev-mxc-001-terraformjdg          |
| Subnet DB                 | snet-utvt-integradora-db-dev-mxc-001-terraformjdg           |
| Subnet VM                 | snet-utvt-integradora-vm-dev-mxc-001-terraformjdg           |
| Subnet PE                 | snet-utvt-integradora-pe-dev-mxc-001-terraformjdg           |
| AzureBastionSubnet        | AzureBastionSubnet                                          |
| PostgreSQL                | psql-utvt-integradora-dev-mxc-001-terraformjdg              |
| Private Endpoint Postgres | pep-utvt-integradora-db-dev-mxc-001-terraformjdg            |
| Storage Account           | stutvtintdevmxc001jdg                                       |
| Private Endpoint Blob     | pep-utvt-integradora-blob-dev-mxc-001-terraformjdg          |
