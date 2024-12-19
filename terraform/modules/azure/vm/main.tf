# Resource Group
resource "azurerm_resource_group" "this" {
  count = var.create ? 1 : 0

  name     = "${local.name_prefix}-rg"
  location = "West US"

  tags = var.tags
}

# Virtual Network
resource "azurerm_virtual_network" "this" {
  count = var.create ? 1 : 0

  name                = "${local.name_prefix}-net"
  address_space       = ["10.0.0.0/16"]
  location            = one(azurerm_resource_group.this[*].location)
  resource_group_name = one(azurerm_resource_group.this[*].name)

  tags = var.tags
}

# Subnet
resource "azurerm_subnet" "this" {
  count = var.create ? 1 : 0

  name                 = "${local.name_prefix}-subnet"
  resource_group_name  = one(azurerm_resource_group.this[*].name)
  virtual_network_name = one(azurerm_virtual_network.this[*].name)
  address_prefixes     = [local.subnet]
}

# Public IP
resource "azurerm_public_ip" "this" {
  count = var.create ? 1 : 0

  name                = "${local.name_prefix}-public-ip"
  location            = one(azurerm_resource_group.this[*].location)
  resource_group_name = one(azurerm_resource_group.this[*].name)
  allocation_method   = "Static"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Network Interface
resource "azurerm_network_interface" "this" {
  count = var.create ? 1 : 0

  name                = "${local.name_prefix}-NIC"
  location            = one(azurerm_resource_group.this[*].location)
  resource_group_name = one(azurerm_resource_group.this[*].name)

  ip_configuration {
    name                          = "internal"
    subnet_id                     = one(azurerm_subnet.this[*].id)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = one(azurerm_public_ip.this[*].id)
  }

  tags = var.tags
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "this" {
  count = var.create ? 1 : 0

  name                = "${local.name_prefix}-vm"
  resource_group_name = one(azurerm_resource_group.this[*].name)
  location            = one(azurerm_resource_group.this[*].location)
  size                = "Standard_DS1_v2"
  admin_username      = "gavin"
  network_interface_ids = [
    one(azurerm_network_interface.this[*].id),
  ]

  admin_ssh_key {
    username   = "gavin"
    public_key = file("~/.ssh/id_ed25519.pub")
  }

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

  identity {
    type         = "UserAssigned"
    identity_ids = azurerm_user_assigned_identity.this[*].id
  }

  tags = var.tags
}

resource "azurerm_management_group" "this" {
  count = var.create ? 1 : 0

  display_name = "${local.name_prefix}-test-mg-${count.index}"
  name         = "${local.name_prefix}-test-mg-${count.index}"

  parent_management_group_id = local.root_management_group_id
}

# Create a Managed Identity
resource "azurerm_user_assigned_identity" "this" {
  count = var.create ? 1 : 0

  name                = "${local.name_prefix}-mi"
  resource_group_name = one(azurerm_resource_group.this[*].name)
  location            = one(azurerm_resource_group.this[*].location)

  tags = var.tags
}

resource "azurerm_role_definition" "self_reader" {
  count = var.create ? 1 : 0

  name              = "${local.name_prefix}-self-reader"
  description       = "Custom role to read a managed identity"
  scope             = one(azurerm_management_group.this[*].id)
  assignable_scopes = azurerm_management_group.this[*].id

  permissions {
    actions = [
      "Microsoft.ManagedIdentity/userAssignedIdentities/read"
    ]
    not_actions = []
  }
}

resource "azurerm_role_definition" "vm_reader" {
  count = var.create ? 1 : 0

  name              = "${local.name_prefix}-vm-reader"
  description       = "Custom role to join teleport"
  scope             = one(azurerm_management_group.this[*].id)
  assignable_scopes = azurerm_management_group.this[*].id

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read"
    ]
    not_actions = []
  }
}

resource "azurerm_role_assignment" "self_reader" {
  count = var.create ? 0 : 0

  principal_id       = one(azurerm_user_assigned_identity.this[*].principal_id)
  role_definition_id = one(azurerm_role_definition.self_reader[*].role_definition_resource_id)
  scope              = one(azurerm_user_assigned_identity.this[*].id)
}

resource "azurerm_role_assignment" "vm_reader" {
  count = var.create ? 0 : 0

  principal_id       = one(azurerm_user_assigned_identity.this[*].principal_id)
  role_definition_id = one(azurerm_role_definition.vm_reader[*].role_definition_resource_id)
  scope              = local.subscription_id
}


# Network Security Group (NSG)
resource "azurerm_network_security_group" "this" {
  count = var.create ? 1 : 0

  name                = "${local.name_prefix}-NSG"
  location            = one(azurerm_resource_group.this[*].location)
  resource_group_name = one(azurerm_resource_group.this[*].name)

  tags = var.tags
}

# NSG Rule to allow SSH from your IP
resource "azurerm_network_security_rule" "allow_ssh" {
  count = var.create ? length(var.allow_public_access_from_cidrs) : 0

  name                        = "${local.name_prefix}-${count.index}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = local.allow_public_access_from_cidrs[count.index]
  destination_address_prefix  = "*"
  resource_group_name         = one(azurerm_resource_group.this[*].name)
  network_security_group_name = one(azurerm_network_security_group.this[*].name)
}

# NSG Rule to block all other inbound traffic
resource "azurerm_network_security_rule" "deny_all_inbound" {
  count = var.create ? 1 : 0

  name                        = "Deny-All-Inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = one(azurerm_resource_group.this[*].name)
  network_security_group_name = one(azurerm_network_security_group.this[*].name)
}

# Associate NSG with the Network Interface
resource "azurerm_network_interface_security_group_association" "this" {
  count = var.create ? 1 : 0

  network_interface_id      = one(azurerm_network_interface.this[*].id)
  network_security_group_id = one(azurerm_network_security_group.this[*].id)
}
