output azdo_service_connection_id {
  value       = azuredevops_serviceendpoint_azurerm.azurerm.id
}
output azdo_service_connection_name {
  description = "The Azure DevOps service connection name"
  value       = var.azdo_service_connection_name
}

output azdo_service_connection_federation_issuer {
  value       = azuredevops_serviceendpoint_azurerm.azurerm.workload_identity_federation_issuer
}
output azdo_service_connection_federation_subject {
  value       = azuredevops_serviceendpoint_azurerm.azurerm.workload_identity_federation_subject
}

output managed_identity_application_id {
  value       = azurerm_user_assigned_identity.identity.client_id
}
output managed_identity_name {
  value       = azurerm_user_assigned_identity.identity.name
}
output managed_identity_principal_id {
  value       = azurerm_user_assigned_identity.identity.principal_id
}