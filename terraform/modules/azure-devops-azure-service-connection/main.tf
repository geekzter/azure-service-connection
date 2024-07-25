data azuredevops_client_config current {}

data azuredevops_project project {
  name                         = var.project_name
}

resource azuredevops_serviceendpoint_azurerm azurerm {
  project_id                   = data.azuredevops_project.project.id
  service_endpoint_name        = var.service_connection_name
  description                  = "Managed by Terraform"
  service_endpoint_authentication_scheme = var.authentication_scheme
  dynamic credentials {
    for_each = range(var.create_identity ? 0 : 1)
    content {
      serviceprincipalid       = var.application_id
      serviceprincipalkey      = var.application_secret
    }
  }  
  azurerm_spn_tenantid         = var.tenant_id
  azurerm_subscription_id      = var.subscription_id
  azurerm_subscription_name    = var.subscription_name
}

resource time_sleep fic_destroy_race_condition {
  depends_on                   = [resource.azuredevops_serviceendpoint_azurerm.azurerm]
  # The service connection destroy will fail if the federated credential is still operational 
  # Wait for Entra to finish removal of the federated credential
  destroy_duration             = "10s"
}