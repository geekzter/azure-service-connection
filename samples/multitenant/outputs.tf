output main_principal_url {
  value       = "https://portal.azure.com/${data.azuread_client_config.current.tenant_id}/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/${data.azuread_service_principal.main_principal.id}/appId/${data.azuread_client_config.default.client_id}/preferredSingleSignOnMode~/null"
}
output peer_principal_url {
  value       = "https://portal.azure.com/${var.peer_tenant_id}/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/${data.azuread_service_principal.peer_principal.id}/appId/${data.azuread_client_config.default.client_id}/preferredSingleSignOnMode~/null"
}
