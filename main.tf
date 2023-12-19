terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.83.0"
    }
  }
}

backend "http" {
   copy = var.copy_existing_state
  }
}

provider "azurerm" {
  subscription_id = "839bbc54-0007-4a78-af76-019b94704e21"
  tenant_id = "5e007b6c-258b-4fde-adc1-8bf8a135885d"
  client_id = "e0fd10c1-26c8-4c51-b680-3a20a5583ab6"
  client_secret = "Npd8Q~U4PJgsFxI-qRI9zXu3uKGPHSB.YNJ7gcqt"
  features {}
  skip_provider_registration = true
}

 resource "azurerm_resource_group" "RG" {
  name     = "DevTestInfra-DEV-RG"
  location = "Southeast Asia"
}

resource "azurerm_resource_group" "DevTestInfra-VNT-RG" {
  name     = "DevTestInfra-VNT-RG"
  location = "Southeast Asia"
}

resource "azurerm_virtual_network" "DevTestInfra-VNT" {
  name                = "DevTestInfra-VNT"
  resource_group_name = azurerm_resource_group.DevTestInfra-VNT-RG.name
  location            = azurerm_resource_group.DevTestInfra-VNT-RG.location
  address_space       = ["10.102.19.0/27"]
}

resource "azurerm_subnet" "snet" {
  name                 = "devtestinfra-snet"
  resource_group_name  = azurerm_resource_group.DevTestInfra-VNT-RG.name
  virtual_network_name = azurerm_virtual_network.DevTestInfra-VNT.name
  address_prefixes     = ["10.102.19.16/28"]
}

resource "azurerm_network_interface" "interfacenic" {
  name                = "interface-nic"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "devtest-nic-ipconfig"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create the Windows VM
resource "azurerm_windows_virtual_machine" "devtestVM" {
  name                = "DT-OGA-DEV-4002"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = "Standard_B2s"
  admin_username      = "azureadmin"
  admin_password      = "CA3@#mw(fg262023"
  network_interface_ids = [
    azurerm_network_interface.interfacenic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}



  

