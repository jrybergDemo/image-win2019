terraform {
  required_providers {
    azurerm = "~> 2.21.0"
    azuread = "~> 0.11.0"
  }

  backend "azurerm" {
    environment          = "USGovernment"
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "${var.image_version}.tfstate"
  }
}

provider "azuread" {
  environment     = "usgovernment"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

provider "azurerm" {
  environment     = "usgovernment"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

data "azurerm_image" "image" {
  name                = var.image_version
  resource_group_name = var.image_rg_name
}

resource "azurerm_virtual_machine" "vm" {
  name                             = var.vm_name
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
  network_interface_ids            = [azurerm_network_interface.nic.id]
  vm_size                          = "Standard_D8s_v3"
  tags                             = var.azure_tags
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  license_type                     = "Windows_Server"

  storage_image_reference {
    id = data.azurerm_image.image.id
  }

  storage_os_disk {
    name              = "OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  os_profile {
    computer_name  = "TestServer"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

resource "azurerm_virtual_machine_extension" "SecureWinRM" {
  name                 = "SecureWinRM"
  virtual_machine_id   = azurerm_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
      "fileUris": [
        "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-winrm-windows/ConfigureWinRM.ps1",
        "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-winrm-windows/makecert.exe",
        "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-winrm-windows/winrmconf.cmd"
      ],
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file ConfigureWinRM.ps1 ${azurerm_public_ip.pip.fqdn}"
    }
  SETTINGS
}
