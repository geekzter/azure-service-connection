terraform {
  required_providers {
    azuredevops = {
      source                   = "microsoft/azuredevops"
      version                  = "~> 1.10"
    }
    azurerm                    = "~> 4.35"
    external                   = "~> 2.3"
    time                       = "~> 0.13"
  }
  required_version             = "~> 1.9"
}

data external azdo_token {
  program                      = [
    "az", "account", "get-access-token", 
    "--resource", "499b84ac-1321-427f-aa17-267ca6975798", # Azure DevOps
    "--query","{accessToken:accessToken}",
    "-o","json"
  ]
}
provider azuredevops {
  org_service_url              = var.azdo_organization_url
  personal_access_token        = data.external.azdo_token.result.accessToken
}

provider azurerm {
  alias                        = "identity"
  features {}
  subscription_id              = provider::azurerm::parse_resource_id(var.managed_identity_resource_group_id)["subscription_id"]
}

provider azurerm {
  alias                        = "target"
  features {}
  subscription_id              = provider::azurerm::parse_resource_id(var.azure_target_scope_id)["subscription_id"]
}