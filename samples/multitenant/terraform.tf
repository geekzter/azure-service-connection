terraform {
  required_providers {
    azuread                    = "~> 2.35"
    # azurerm                    = "~> 4.6"
    # cloudinit                  = "~> 2.2"
    # http                       = "~> 3.4"
    # local                      = "~> 2.1"
    # null                       = "~> 3.1"
    # random                     = "~> 3.1"
    # time                       = "~> 0.7"
  }
  required_version             = "~> 1.0"
}

# Microsoft Azure Resource Manager Provider
provider azuread {
  tenant_id                    = var.tenant_id
}
data azuread_client_config default {}

# Multi-tenant multi-provider
provider azuread {
  alias                        = "peer"
  client_id                    = data.azuread_client_config.default.client_id
  tenant_id                    = var.peer_tenant_id
# Requires admin consent:
# https://login.microsoftonline.com/${var.peer_tenant_id}/adminconsent?client_id=${data.azuread_client_config.default.client_id}
#   auxiliary_tenant_ids         = local.use_peer && var.peer_tenant_id != null && var.peer_tenant_id != "" ? [data.azurerm_subscription.default.tenant_id] : []
}
data azuread_client_config peer {
  provider                     = azurerm.peer
}
