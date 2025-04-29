data azuread_service_principal main_principal {
  client_id                    = data.azuread_client_config.default.client_id
}

data azuread_service_principal peer_principal {
  provider                     = azuread.peer
  client_id                    = data.azuread_client_config.default.client_id
}