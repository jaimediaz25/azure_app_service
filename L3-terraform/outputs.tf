output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  value = { for k, s in azurerm_subnet.subnets : k => s.id }
}

output "bastion_id" {
  value = azurerm_bastion_host.bastion.id
}

output "vm_private_ip" {
  value = azurerm_network_interface.vm.private_ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.worker.id
}

output "app_service_default_hostname" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "app_service_id" {
  value = azurerm_linux_web_app.app.id
}

output "postgresql_fqdn" {
  value = azurerm_postgresql_flexible_server.psql.fqdn
}

output "postgresql_id" {
  value = azurerm_postgresql_flexible_server.psql.id
}

output "storage_account_name" {
  value = azurerm_storage_account.blob.name
}

output "storage_account_id" {
  value = azurerm_storage_account.blob.id
}

output "private_endpoint_psql_id" {
  value = azurerm_private_endpoint.psql.id
}

output "private_endpoint_blob_id" {
  value = azurerm_private_endpoint.blob.id
}
