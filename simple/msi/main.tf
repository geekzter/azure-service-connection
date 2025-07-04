# data azurerm_client_config current {}
data azurerm_subscription target {
  provider                     = azurerm.target
}
data azuredevops_project project {
  name                         = var.azdo_project_name
}

data azurerm_resource_group identity {
  provider                     = azurerm.identity
  name                         = provider::azurerm::parse_resource_id(var.managed_identity_resource_group_id)["resource_group_name"]
}

resource azurerm_user_assigned_identity identity {
  provider                     = azurerm.identity
  location                     = data.azurerm_resource_group.identity.location
  name                         = replace(element(split("/",var.azdo_service_connection_name),-1),"/\\W+/","-")
  resource_group_name          = data.azurerm_resource_group.identity.name
}

resource azuredevops_serviceendpoint_azurerm azurerm {
  project_id                   = data.azuredevops_project.project.id
  service_endpoint_name        = var.azdo_service_connection_name
  description                  = "Managed by Terraform"
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"
  credentials {
    serviceprincipalid         = azurerm_user_assigned_identity.identity.client_id
  }  
  azurerm_spn_tenantid         = data.azurerm_subscription.target.tenant_id
  azurerm_subscription_id      = data.azurerm_subscription.target.subscription_id
  azurerm_subscription_name    = data.azurerm_subscription.target.display_name
}

resource time_sleep fic_destroy_race_condition {
  depends_on                   = [azuredevops_serviceendpoint_azurerm.azurerm]
  destroy_duration             = "30s"
}

resource azurerm_federated_identity_credential fic {
  provider                     = azurerm.identity
  name                         = azuredevops_serviceendpoint_azurerm.azurerm.id
  resource_group_name          = data.azurerm_resource_group.identity.name
  audience                     = ["api://AzureADTokenExchange"]
  issuer                       = azuredevops_serviceendpoint_azurerm.azurerm.workload_identity_federation_issuer
  parent_id                    = azurerm_user_assigned_identity.identity.id
  subject                      = azuredevops_serviceendpoint_azurerm.azurerm.workload_identity_federation_subject
  depends_on                   = [time_sleep.fic_destroy_race_condition]
}

resource azurerm_role_assignment resouce_access {
  provider                     = azurerm.target
  scope                        = var.azure_target_scope_id
  role_definition_name         = "Contributor"
  principal_id                 = azurerm_user_assigned_identity.identity.principal_id
}