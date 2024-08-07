variable azdo_creates_identity {
  description                  = "Let Azure DevOps create identity for service connection"
  default                      = false
  type                         = bool
}

variable azdo_organization_url {
  description                  = "The Azure DevOps organization URL (e.g. https://dev.azure.com/contoso)"
  nullable                     = false
  type                         = string
}
variable azdo_project_name {
  description                  = "The Azure DevOps project name to create the service connection in"
  nullable                     = false
  type                         = string
}

variable azdo_service_connection_type {
  type                         = string
  default                      = "Azure"
  description                  = "The type of service connection to create. Valid values are 'Azure' and 'ACR'."
  nullable                     = false
  validation {
    condition                  = var.azdo_service_connection_type == "Azure" || var.azdo_service_connection_type == "ACR"
    error_message              = "The credential_type must be 'Azure' or 'ACR'"
  }
}

variable azure_container_registry_name {
  description                  = "The Azure Container Registry name"
  default                      = null
  nullable                     = true
  type                         = string
  validation {
    condition                  = var.azure_container_registry_name == "ACR" ? length(var.azure_container_registry_name) > 0 : true
    error_message              = "You must specify a value for azure_container_registry_name if azdo_service_connection_type is 'ACR'."
  }
}

variable azure_role_assignments {
  default                      = null
  description                  = "Role assignments to create for the service connection's identity. If this is empty, the Contributor role will be assigned on the azurerm provider subscription."
  nullable                     = true
  type                         = set(object({scope=string, role=string}))
}

variable create_managed_identity {
  description                  = "Creates a Managed Identity instead of a App Registration"
  default                      = false
  type                         = bool
}

variable credential_type {
  type                         = string
  default                      = "FederatedIdentity"
  description                  = "The type of credential to use for the service connection. Valid values are 'FederatedIdentity' and 'Secret'."
  nullable                     = false
  validation {
    condition                  = var.credential_type == "FederatedIdentity" || var.credential_type == "Secret"
    error_message              = "The credential_type must be 'FederatedIdentity' or 'Secret'"
    # TODO: Depends on https://github.com/microsoft/terraform-provider-azuredevops/issues/409
    # condition                  = var.credential_type == "Certificate" || var.credential_type == "FederatedIdentity" || var.credential_type == "Secret"
    # error_message              = "The credential_type must be 'Certificate', 'FederatedIdentity' or 'Secret'"
  }
  validation {
    condition                  = !(var.credential_type == "Secret" && var.azdo_service_connection_type == "ACR" && var.azdo_creates_identity)
    error_message              = "The combination azdo_service_connection_type 'ACR, credential_type 'Secret' and azdo_creates_identity 'true' is not supported."
  }
}

variable entra_app_notes {
  default                      = null
  description                  = "Description to put in the Entra ID app registration notes field"
  type                         = string
}

variable entra_app_owner_object_ids {
  default                      = null
  description                  = "Object ids of the users that will be co-owners of the Entra ID app registration"
  type                         = list(string)
}

variable entra_security_group_names {
  default                      = []
  description                  = "Names of the security groups to add the service connection identity to"
  nullable                     = false
  type                         = list(string)
}

variable entra_secret_expiration_days {
  description                  = "Secret expiration in days"
  default                      = 90
  type                         = number
}

variable entra_service_management_reference {
  default                      = null
  description                  = "IT Service Management Reference to add to the App Registration"
  type                         = string
}

variable managed_identity_resource_group_id {
  default                      = null
  description                  = "The resource group to create the Managed Identity in"
  type                         = string
}

variable resource_prefix {
  description                  = "The prefix to put in front of resource names created"
  default                      = "demo"
  nullable                     = false
  type                         = string
}
variable resource_suffix {
  description                  = "The suffix to append to resource names created"
  default                      = "" # Empty string triggers a random suffix
  type                         = string
}
variable run_id {
  description                  = "The ID that identifies the pipeline / workflow that invoked Terraform (used in CI/CD)"
  default                      = null
  type                         = number
}