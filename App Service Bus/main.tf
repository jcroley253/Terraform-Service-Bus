# service bus - np

provider "azurerm" {
    features {}
    version = ">=2.7"
    tenant_id       = var.tenant_id
    subscription_id = var.subscription_id
}

provider "cwiam" {
  default_computer_account_ou = var.default_computer_account_ou
  iam_ssh_server_host_keys = var.iam_ssh_server_host_keys
  iam_ssh_server_name = var.iam_ssh_server_name
}

resource "azurerm_resource_group" "rg_name" {
  name     = "${var.environment}-TFProjectName-${var.location}-rg"
  location = var.location
}

resource "azurerm_subnet" "rmod_snet" {
  name                                           = var.virtual_subnet_name
  resource_group_name                            = var.virtual_network_resource_group
  virtual_network_name                           = var.virtual_network_name
  address_prefixes                               = [var.virtual_subnet_address]
  enforce_private_link_endpoint_network_policies = true

  service_endpoints = ["Microsoft.ServiceBus"]
}

resource "azurerm_servicebus_namespace" "rmod_sbn" {
  name                = "${var.environment}-rmod-${var.location}-sbn"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_name.name
  sku                 = "Premium"
  capacity            = 4

  zone_redundant = true

  tags = {
    "CreatorName"   = var.creator
    "SupportEmail"  = var.email
    "Project"       = var.project
    }
}

resource "azurerm_servicebus_namespace_authorization_rule" "rmod_sbn_rule" {
    name                = "${var.environment}-rmod-${var.location}-sbn-rule"
    namespace_name      = azurerm_servicebus_namespace.rmod_sbn.name
    resource_group_name = azurerm_resource_group.rg_name.name

    listen = true
    send   = true
    manage = true
}

resource "azurerm_private_endpoint" "sbn_endpoint" {
 name                = "${var.environment}-rmod-${var.location}-ep"
 location            = var.location
 resource_group_name = azurerm_resource_group.rg_name.name
 subnet_id           = azurerm_subnet.rmod_snet.id
 private_service_connection {
   name                           = "${var.environment}-rmod-${var.location}-psc"
   is_manual_connection           = false
   private_connection_resource_id = azurerm_servicebus_namespace.rmod_sbn.id
   subresource_names              = ["namespace"]
    }
}

resource "cwiam_dns_a_record" "sbn_Arecord" {
 name        = azurerm_servicebus_namespace.rmod_sbn.name
 zone_name   = "privatelink.servicebus.windows.net"
 ip_address  = [azurerm_private_endpoint.sbn_endpoint.custom_dns_configs[0].ip_addresses[0]]
 ttl         = 300
}

#alerting
resource "azurerm_monitor_action_group" "rg_name_actionGroup" {
 name = "Alert-Group"
 resource_group_name = azurerm_resource_group.rg_name.name
 short_name = "Alert-Group"

  email_receiver {
    name = "email-john"
    email_address = "jcroley@domain.com"
  }
}
#need to figure out naming structure with multiple rules
resource "azurerm_monitor_metric_alert" "projectname_rule1" { 
 name = "rule1"
 resource_group_name = azurerm_resource_group.rg_name.name
 scopes = [azurerm_servicebus_namespace.projectname_sbn.id]
 description = "this is a test to see if i can generate rule utilizing terraform"

 criteria {
   metric_namespace = "Microsoft.ServiceBus/namespaces"
   metric_name = "Messages"
   aggregation = "Average"
   operator = "GreaterThan"
   threshold = 10

   dimension {
     name = "EntityName"
     operator = "Include"
     values = ["*"]
   }
 }
 action {
   action_group_id = azurerm_monitor_action_group.rg_name_actionGroup.id
 }
}