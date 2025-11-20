terraform {
  required_providers {
    azuread                    = "~> 2.40"
    azuredevops = {
      source                   = "microsoft/azuredevops"
      version                  = "~> 1.2"
    }
    azurerm                    = "~> 4.6"
    external                   = "~> 2.3"
    http                       = "~> 3.4"
    random                     = "~> 3.5"
    time                       = "~> 0.9"
  }
  required_version             = "~> 1.9"
}

provider azuredevops {
  org_service_url              = local.azdo_organization_url
}

provider azurerm {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  # skip_provider_registration   = true
}

provider azurerm {
  alias                        = "managed_identity"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id              = local.managed_identity_subscription_id
}

provider azurerm {
  alias                        = "target"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id              = data.azurerm_subscription.target.subscription_id
}