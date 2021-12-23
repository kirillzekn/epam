# Configure the Azure Provider
terraform {
  required_version = ">= 1.0.0"
  backend "azurerm" { }
}

provider "azurerm" {
features {}
}
# Create a resource group
resource "azurerm_resource_group" "example_rg" {
    name = "${var.resource-prefix}-RG"
    location = var.node_location
}
# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example_vnet" {
    name = "${var.resource-prefix}-vnet"
    resource_group_name = azurerm_resource_group.example_rg.name
    location = var.node_location
    address_space = var.node_address_space
}
# Create a subnets within the virtual network
resource "azurerm_subnet" "example_subnet" {
    name = "${var.resource-prefix}-subnet"
    resource_group_name = azurerm_resource_group.example_rg.name
    virtual_network_name = azurerm_virtual_network.example_vnet.name
    address_prefixes = var.node_address_prefixes
}
# Create Linux Public IP
resource "azurerm_public_ip" "example_public_ip" {
    count = var.node_count
    name = "${var.resource-prefix}-${count.index}-PublicIP"
    #name = "${var.resource-prefix}-PublicIP"
    location = azurerm_resource_group.example_rg.location
    resource_group_name = azurerm_resource_group.example_rg.name
    allocation_method = var.Environment == "Test" ? "Static" : "Dynamic"
    tags = {
    environment = "Test"
    }
}
# Create Network Interface
resource "azurerm_network_interface" "example_nic" {
    count = var.node_count
    #name = "${var.resource-prefix}-NIC"
    name = "${var.resource-prefix}-${count.index}-NIC"
    location = azurerm_resource_group.example_rg.location
    resource_group_name = azurerm_resource_group.example_rg.name
#
ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = element(azurerm_public_ip.example_public_ip.*.id, count.index)
#public_ip_address_id = azurerm_public_ip.example_public_ip.id
#public_ip_address_id = azurerm_public_ip.example_public_ip.id
    }
}
# Creating resource NSG
resource "azurerm_network_security_group" "example_nsg" {
    name = "${var.resource-prefix}-NSG"
    location = azurerm_resource_group.example_rg.location
    resource_group_name = azurerm_resource_group.example_rg.name
# Security rule can also be defined with resource azurerm_network_security_rule, here just defining it inline.
security_rule {
    name = "Inbound"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    }
    tags = {
    environment = "Test"
    }
}
# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "example_subnet_nsg_association" {
    subnet_id = azurerm_subnet.example_subnet.id
    network_security_group_id = azurerm_network_security_group.example_nsg.id
}


resource "azurerm_linux_virtual_machine" "zekn-linux" {
    count = var.node_count
    name = "${var.resource-prefix}-${count.index}"
    #name = "${var.resource-prefix}-VM"
    location = azurerm_resource_group.example_rg.location
    resource_group_name = azurerm_resource_group.example_rg.name
    network_interface_ids = [element(azurerm_network_interface.example_nic.*.id, count.index)]
    size = "Standard_B1ms"
    admin_username      = var.admin_ssh_username


  admin_ssh_key {
    username   = var.admin_ssh_username
    public_key = file(var.admin_ssh_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8.0"
    version   = "latest"
    }
}

resource "azurerm_virtual_machine_extension" "example" {
  name                 = "hostname"
  virtual_machine_id   = element(azurerm_linux_virtual_machine.zekn-linux.*.id, 0) 
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo yum install -y epel-release && sudo yum install -y ansible"
    }
SETTINGS


}