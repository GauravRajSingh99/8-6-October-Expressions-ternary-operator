# variable "dhondhu" {
#     default = "tony"
# }

# resource "azurerm_resource_group" "rg" {
#     name = "rg-${var.dhondhu}"
#     location = "westus"
# }

# resource "azurerm_resource_group" "rg" {
#     name = 1+1
#     location = "westus"
# }

# resource "azurerm_resource_group" "rg" {
#     name = "rg-${79==79}-${var.dhondhu}"
#     location = "westus"
# }

# resource "azurerm_resource_group" "rg" {
#     name = 79 != 79
#     location = "westus"
# }

# resource "azurerm_resource_group" "rg" {
#     name = 79 != 80
#     location = "westus"
# }

# resource "azurerm_resource_group" "rg" {
#     name = true||false
#     location = "westus"
# }

# resource "azurerm_resource_group" "rg" {
#     name = false||false
#     location = "westus"                    #Answer = false
# }

# resource "azurerm_resource_group" "rg" {
#     name = true&&false
#     location = "westus"                   #Answer = false
# }

# resource "azurerm_resource_group" "rg" {
#     name = true&&true
#     location = "westus"                   #Answer = true
# }

# resource "azurerm_resource_group" "rg" {
#     name = 79==79 && 78!=79
#     location = "westus"                    #Answer = true
# }


# resource "azurerm_resource_group" "rg" {
#     name = true ? "dhondhu" : "tondu"
#     location = "westus"                     #Answer = dhondhu
# }

# resource "azurerm_resource_group" "rg" {
#     name = false ? "dhondhu" : "tondu"
#     location = "westus"                     #Answer = tondu
# }


##################Ternary operator

# resource "azurerm_resource_group" "rg" {
#     name = 79==79 ? "dhondhu" : "tondu"
#     location = "westus"                     #Answer = dhondhu
# }

# resource "azurerm_resource_group" "rg" {
#     name = 78==79 ? "dhondhu" : "tondu"
#     location = "westus"                     #Answer = tondu
# }

# resource "azurerm_resource_group" "rg" {
#     name = var.dhondhu == "tony" && 64329!=64328 ? "dhondhu" : "tondu"
#     location = "westus"                     #Answer = dhondhu
# }

# resource "azurerm_resource_group" "rg" {
#     name = var.dhondhu == "tony1" && 64329!=64328 ? "dhondhu" : "tondu"
#     location = "westus"                     #Answer = tondu
# }

# resource "azurerm_resource_group" "rg" {
#     name = "rg-${var.dhondhu}" == "tony" && 64329!=64328 ? "dhondhu" : "tondu"
#     location = "westus"                     #Answer = tondu
# }

# resource "azurerm_resource_group" "rg" {
#     name = "rg-${var.dhondhu}" == "tony" || 64329!=64328 ? "dhondhu" : "tondu"
#     location = "westus"                     #Answer = dhondhu
# }

variable "name" {}
variable "enable_public_ip" {}

resource "azurerm_resource_group" "rg" {
    name      = "rg-${var.name}"
    location  = "westus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.name}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "pip-${var.name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "example" {
  name                = "nic-${var.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.pip[0].id : null #we put [0] as per implicit dependency
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-${var.name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

disable_password_authentication = true
admin_password = "Mommy7Daddy!"


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}