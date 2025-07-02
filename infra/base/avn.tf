/*
# Commented out resources not required for Azure Container Apps setup
resource "azurerm_virtual_network" "virtual-network" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.virtual_network_address_space
}

resource "azurerm_subnet" "public_subnet_a" {
  name                 = var.subnet_a_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual-network.name
  address_prefixes     = var.subnet_a_address_prefixes
}

resource "azurerm_subnet" "public_subnet_b" {
  name                 = var.subnet_b_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual-network.name
  address_prefixes     = var.subnet_b_address_prefixes
}

# Define services and their specific configurations
locals {
  services = {
    quotes = {
      public_ip_sku      = var.quotes_public_ip_sku
      subnet_id          = azurerm_subnet.public_subnet_a.id
      inbound_port       = var.quotes_inbound_port
      rules              = var.quotes_rules
    },
    newsfeed = {
      public_ip_sku      = var.newsfeed_public_ip_sku
      subnet_id          = azurerm_subnet.public_subnet_a.id
      inbound_port       = var.newsfeed_inbound_port
      rules              = var.newsfeed_rules
    },
    frontend = {
      public_ip_sku      = var.frontend_public_ip_sku
      subnet_id          = azurerm_subnet.public_subnet_b.id
      inbound_port       = var.frontend_inbound_port
      rules              = var.frontend_rules
    }
  }
  # Flatten rules for for_each in security rules
  flattened_rules = flatten([
    for service, config in local.services : [
      for rule in config.rules : {
        key = "${service}-${rule.type}"
        service = service
        type = rule.type
        priority = rule.priority
        direction = rule.direction
        port_range = rule.port_range
        dest_prefix = rule.dest_prefix
      }
    ]
  ])
}

resource "azurerm_public_ip" "public-ip" {
  for_each            = local.services
  name                = "public-ip-${each.key}"
  resource_group_name = var.resource_group_name
  location            = azurerm_virtual_network.virtual-network.location
  allocation_method   = "Static"
  sku                 = each.value.public_ip_sku
}

resource "azurerm_route_table" "route-table" {
  name                          = var.route_table_name
  location                      = azurerm_virtual_network.virtual-network.location
  resource_group_name           = azurerm_virtual_network.virtual-network.resource_group_name

  route {
    name           = var.route_name
    address_prefix = var.route_address_prefix
    next_hop_type  = var.route_next_hop_type
  }

  tags = {
    environment = var.route_table_tag_environment
  }
}

resource "azurerm_subnet_route_table_association" "association-subnet-a" {
  subnet_id      = azurerm_subnet.public_subnet_a.id
  route_table_id = azurerm_route_table.route-table.id
}

resource "azurerm_subnet_route_table_association" "association-subnet-b" {
  subnet_id      = azurerm_subnet.public_subnet_b.id
  route_table_id = azurerm_route_table.route-table.id
}

resource "azurerm_network_security_group" "security-group" {
  for_each            = local.services
  name                = "security-group-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "rule" {
  for_each                    = { for rule in local.flattened_rules : rule.key => rule }
  name                        = "rule-${each.value.type}-${each.value.service}"
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.port_range
  source_address_prefix       = "*"
  destination_address_prefix  = each.value.dest_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.security-group[each.value.service].name
}

resource "azurerm_network_interface" "network-interface" {
  for_each            = local.services
  name                = "network-interface-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "association-ni-sg" {
  for_each                  = local.services
  network_interface_id      = azurerm_network_interface.network-interface[each.key].id
  network_security_group_id = azurerm_network_security_group.security-group[each.key].id
}
*/
