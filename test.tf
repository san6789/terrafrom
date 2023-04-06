module "azurerm_resource_group" {
  source              = "git::xxxxxx/_git/xxxxxx//modules/azure/resourcegroup?ref=main"
  resource_group_name = var.resource_group_name
}

module "azurerm_virtual_vnetsubet" {
  source              = "git::xxxxxx/_git/xxxxxx//modules/azure/vnet-subnet?ref=main"
  vnetname            = var.vnetname
  subnetname          = var.subnetname
  resource_group_name = module.azurerm_resource_group.name
}

module "azurerm_network_security_group" {
  source              = "git::xxxxxx/_git/xxxxxx//modules/azure/network-security-group?ref=main"
  nsgname             = var.nsgname
  resource_group_name = module.azurerm_resource_group.name
}

# create new network network_interface
module "azurerm_network_interface" {
  source              = "git::xxxxxx/_git/xxxxxx//modules/azure//network-interface?ref=main"
  resource_group_name = module.azurerm_resource_group.name
  location            = module.azurerm_resource_group.location
  nic-name            = var.nic-name
  ipname              = var.ipname
  subnetid            = module.azurerm_virtual_vnetsubet.subnetid
}

# use existing keyvault to read 
module "azurerm_key_vault" {
  source                              = "git::xxxxxx/_git/xxxxxx//modules/azure/data-key-vault?ref=main"
  keyvault_name                       = var.keyvault_name
  keyvault_resource_group_name        = var.keyvault_resource_group_name
  keyvault_admin_password_secret_name = var.keyvault_admin_password_secret_name

}

module "azurerm_image" {
  source                     = "git::xxxxxx/_git/xxxxxx//modules/azure/image?ref=main"
  custom_image               = var.custom_image
  customimage_resource_group = var.customimage_resource_group
}

module "azurerm_proximity_placement_group" {
  source               = "git::xxxxxx/_git/xxxxxx//modules/azure/proximity-placement-group?ref=main"
  proximity_group_name = var.proximity_group_name
  location             = module.azurerm_resource_group.location
  resource_group_name  = module.azurerm_resource_group.name
}

module "vmss" {
  source                       = "git::xxxxxx/_git/xxxxxx//modules/azure/vmss-linux?ref=main"
  vmss_name                    = var.vmss_name
  location                     = module.azurerm_resource_group.location
  resource_group_name          = module.azurerm_resource_group.name
  source_image_id              = module.azurerm_image.id
  proximity_placement_group_id = module.azurerm_proximity_placement_group.id
  proximity_group_name         = var.proximity_group_name
  computer_prefix              = var.computer_prefix
  sku                          = var.sku
  admin_username               = var.admin_username
  admin_password               = module.azurerm_key_vault.value
  os_storage_account_type      = var.os_storage_account_type
  extra_disk                   = var.extra_disk
  subnet_id                    = module.azurerm_virtual_vnetsubet.subnetid
  overprovision                = var.overprovision
  instances                    = var.instances
}



vmss scale set linux:

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = var.vmss_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  sku                             = var.sku
  instances                       = var.instances
  upgrade_mode                    = "Manual"
  source_image_id                 = var.source_image_id
  proximity_placement_group_id    = var.proximity_placement_group_id
  computer_name_prefix            = var.computer_prefix
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  overprovision                   = var.overprovision

  os_disk {
    storage_account_type = var.os_storage_account_type
    caching              = "ReadWrite"
  }
  data_disk {
    lun                  = 0
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    create_option        = "Empty"
    disk_size_gb         = var.extra_disk

  }

  identity {
    type = "SystemAssigned"
  }

  network_interface {
    name    = "vmssinterface"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id

    }
  }
}


image:


outputfile:

output "name" {
  value       = data.azurerm_resource_group.rg.name
  description = "The resource group."
}

output "location" {
  value       = data.azurerm_resource_group.rg.location
  description = "The location of the resource group."
}

this is going to refer in module.azurerm_resource_group.name like 
module.azurerm_resource_group.location

