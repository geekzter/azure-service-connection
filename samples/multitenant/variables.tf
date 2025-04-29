variable tenant_id {
  description                  = "Configure tenant_id independent from ARM_TENANT_ID"
  default                      = null
}
variable packer_tenant_id {
  description                  = "When building images in a cross-tenant peered virtual network, this is needed"
  default                      = null
}