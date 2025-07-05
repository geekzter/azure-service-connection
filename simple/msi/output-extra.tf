output azdo_service_connection_url {
  value       = "${var.azdo_organization_url}/${replace(var.azdo_project_name, " ", "%20")}/_settings/adminservices?resourceId=${azuredevops_serviceendpoint_azurerm.azurerm.id}"
}
output azure_target_scope_url {
  value       = "https://portal.azure.com/#@${azurerm_user_assigned_identity.identity.tenant_id}/resource${var.azure_target_scope_id}/users"
}
output managed_identity_identity_url {
  value       = "https://portal.azure.com/#@${azurerm_user_assigned_identity.identity.tenant_id}/resource${azurerm_user_assigned_identity.identity.id}/azure_resources"
}
output managed_identity_principal_url {
  value       = "https://portal.azure.com/${azurerm_user_assigned_identity.identity.tenant_id}/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/${azurerm_user_assigned_identity.identity.principal_id}/appId/${azurerm_user_assigned_identity.identity.client_id}"
}