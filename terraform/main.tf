data azurerm_client_config current {}
data azurerm_subscription current {}
data azurerm_subscription target {
  subscription_id              = length(local.azure_role_assignments) > 0 ? split("/",tolist(local.azure_role_assignments)[0].scope)[2] : data.azurerm_subscription.current.subscription_id
}

# Random resource suffix, this will prevent name collisions when creating resources in parallel
resource random_string suffix {
  length                       = 4
  upper                        = false
  lower                        = true
  numeric                      = false
  special                      = false
}

locals {
  application_id               = var.azdo_creates_identity ? null : (var.create_managed_identity ? module.managed_identity.0.application_id : module.entra_app.0.application_id)
  authentication_scheme_map     = {
    # Certificate                 = "ServicePrincipal", # TODO: Depends on https://github.com/microsoft/terraform-provider-azuredevops/issues/409
    FederatedIdentity           = "WorkloadIdentityFederation",
    Secret                      = "ServicePrincipal",
  }
  authentication_scheme        = local.authentication_scheme_map[var.credential_type]
  azdo_organization_name       = split("/",var.azdo_organization_url)[3]
  azdo_organization_url        = replace(var.azdo_organization_url,"/\\/$/","")
  azdo_project_url             = "${local.azdo_organization_url}/${urlencode(var.azdo_project_name)}"
  azdo_service_connection_name = "${replace(data.azurerm_subscription.target.display_name,"/ +/","-")}${terraform.workspace == "default" ? "" : format("-%s",terraform.workspace)}-${local.resource_suffix}"
  azure_role_assignments       = var.azure_role_assignments != null ? var.azure_role_assignments : [
    {
      # Default role assignment
      role                     = "Contributor"
      scope                    = data.azurerm_subscription.current.id
    }
  ]
  managed_identity_subscription_id = var.create_managed_identity ? split("/", var.managed_identity_resource_group_id)[2] : null
  notes                        = coalesce(var.entra_app_notes,"Azure DevOps ${var.azdo_service_connection_type} Service Connection ${local.azdo_service_connection_name} in project ${local.azdo_project_url}. Managed by Terraform: https://github.com/geekzter/azure-service-connection.")
  principal_id                 = var.azdo_creates_identity ? null : (var.create_managed_identity ? module.managed_identity.0.principal_id : module.entra_app.0.principal_id)
  principal_name               = var.azdo_creates_identity ? null : (var.create_managed_identity ? module.managed_identity.0.principal_name : module.entra_app.0.principal_name)
  project_id                   = var.azdo_service_connection_type == "ACR" ? module.acr_service_connection.0.project_id : module.azure_service_connection.0.project_id
  resource_suffix              = var.resource_suffix != null && var.resource_suffix != "" ? lower(var.resource_suffix) : random_string.suffix.result
  resource_tags                = {
    application                = "Azure Service Connection"
    githubRepo                 = "https://github.com/geekzter/azure-identity-scripts"
    provisioner                = "terraform"
    provisionerClientId        = data.azurerm_client_config.current.client_id
    provisionerObjectId        = data.azurerm_client_config.current.object_id
    repository                 = "azure-identity-scripts"
    runId                      = var.run_id
    workspace                  = terraform.workspace
  }
  service_connection_id        = var.azdo_service_connection_type == "ACR" ? module.acr_service_connection.0.service_connection_id : module.azure_service_connection.0.service_connection_id
  service_connection_oidc_issuer = var.azdo_service_connection_type == "ACR" ? module.acr_service_connection.0.service_connection_oidc_issuer : module.azure_service_connection.0.service_connection_oidc_issuer
  service_connection_oidc_subject = var.azdo_service_connection_type == "ACR" ? module.acr_service_connection.0.service_connection_oidc_subject : module.azure_service_connection.0.service_connection_oidc_subject
  service_connection_url       = var.azdo_service_connection_type == "ACR" ? module.acr_service_connection.0.service_connection_url : module.azure_service_connection.0.service_connection_url
}

resource terraform_data managed_identity_validator {
  triggers_replace             = [
    var.create_managed_identity,
    var.managed_identity_resource_group_id
  ]

  lifecycle {
    precondition {
      condition                = var.create_managed_identity && can(split("/", var.managed_identity_resource_group_id)[4])
      error_message            = "managed_identity_resource_group_id is required when create_managed_identity is true"
    }
  }

  count                        = var.create_managed_identity ? 1 : 0  
}

module managed_identity {
  providers                    = {
    azurerm                    = azurerm.managed_identity
  }
  source                       = "./modules/azure-managed-identity"
  federation_subject           = local.service_connection_oidc_subject
  issuer                       = local.service_connection_oidc_issuer
  name                         = "${var.resource_prefix}-${lower(var.azdo_service_connection_type)}-service-connection-${terraform.workspace}-${local.resource_suffix}"
  resource_group_name          = split("/", var.managed_identity_resource_group_id)[4]
  tags                         = local.resource_tags

  count                        = var.create_managed_identity ? 1 : 0
  depends_on                   = [terraform_data.managed_identity_validator]
}

module entra_app {
  source                       = "./modules/entra-application"
  create_federation            = var.credential_type == "FederatedIdentity"
  create_secret                = var.credential_type == "Secret"
  federated_identity_credential_name = local.azdo_service_connection_name
  federation_subject           = var.credential_type == "FederatedIdentity" ? local.service_connection_oidc_subject : null
  issuer                       = var.credential_type == "FederatedIdentity" ? local.service_connection_oidc_issuer  : null
  multi_tenant                 = var.entra_app_multi_tenant
  name                         = "${var.resource_prefix}-${lower(var.azdo_service_connection_type)}-service-connection-${terraform.workspace}-${local.resource_suffix}"
  notes                        = local.notes
  owner_object_ids             = var.entra_app_owner_object_ids
  secret_expiration_days       = var.entra_secret_expiration_days
  service_management_reference = var.entra_service_management_reference

  count                        = var.create_managed_identity || var.azdo_creates_identity ? 0 : 1
}

module acr_service_connection {
  source                       = "./modules/azure-devops-acr-service-connection"
  acr_name                     = var.azure_container_registry_name
  application_id               = local.application_id
  application_secret           = var.azdo_creates_identity || var.credential_type == "FederatedIdentity" ? null : module.entra_app.0.secret
  authentication_scheme        = local.authentication_scheme
  create_identity              = var.azdo_creates_identity
  project_name                 = var.azdo_project_name
  tenant_id                    = data.azurerm_client_config.current.tenant_id
  service_connection_name      = local.azdo_service_connection_name
  subscription_id              = data.azurerm_subscription.target.subscription_id
  subscription_name            = data.azurerm_subscription.target.display_name

  count                        = var.azdo_service_connection_type == "ACR" ? 1 : 0
}

module azure_service_connection {
  source                       = "./modules/azure-devops-azure-service-connection"
  application_id               = local.application_id
  application_secret           = var.azdo_creates_identity || var.credential_type == "FederatedIdentity" ? null : module.entra_app.0.secret
  authentication_scheme        = local.authentication_scheme
  create_identity              = var.azdo_creates_identity
  project_name                 = var.azdo_project_name
  tenant_id                    = data.azurerm_client_config.current.tenant_id
  service_connection_name      = local.azdo_service_connection_name
  subscription_id              = data.azurerm_subscription.target.subscription_id
  subscription_name            = data.azurerm_subscription.target.display_name

  count                        = var.azdo_service_connection_type == "Azure" ? 1 : 0
}