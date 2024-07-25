output project_id {
  value       = data.azuredevops_project.project.project_id
}
output service_connection_id {
  value       = azuredevops_serviceendpoint_azurecr.azurerm.id
}
output service_connection_oidc_issuer {
  value       = azuredevops_serviceendpoint_azurecr.azurerm.workload_identity_federation_issuer
  depends_on  = [time_sleep.fic_destroy_race_condition]
}
output service_connection_oidc_subject {
  value       = azuredevops_serviceendpoint_azurecr.azurerm.workload_identity_federation_subject
  depends_on  = [time_sleep.fic_destroy_race_condition]
}
output service_connection_url {
  value       = "${data.azuredevops_client_config.current.organization_url}/${replace(var.project_name," ","%20")}/_settings/adminservices?resourceId=${azuredevops_serviceendpoint_azurecr.azurerm.id}"
}