# Current Azure context
data "azurerm_client_config" "me" {}
data "azurerm_subscription" "current" {}

# Resource group for the Key Vault
resource "azurerm_resource_group" "rg" {
  name     = var.openbao_rg
  location = var.azure_location
}

# Main Key Vault instance for Vault auto-unseal
resource "azurerm_key_vault" "kv" {
  name                        = var.openbao_key_name
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  tenant_id                   = data.azurerm_client_config.me.tenant_id

  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  rbac_authorization_enabled = true
}

# RSA key used by OpenBao for seal/unseal operations
resource "azurerm_key_vault_key" "openbao_unseal" {
  name         = var.openbao_vault_key
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 3072
  key_opts     = ["wrapKey", "unwrapKey"]

  depends_on   = [
    azurerm_role_assignment.me_kv_admin
  ]
}

# Azure AD application and service principal used by OpenBao
resource "azuread_application_registration" "openbao" {
  display_name = var.azure_sp_openbao
}

resource "azuread_service_principal" "openbao_sp" {
  client_id = azuread_application_registration.openbao.client_id
}

# Client secret for the SP
resource "azuread_application_password" "openbao_sp_secret" {
  application_id = azuread_application_registration.openbao.id
  display_name   = var.azure_unseal_sp_openbao_secret_name
  end_date       = timeadd(timestamp(), "17520h") # ~2 years
}

# Grant the farmer) full Key Vault admin rights
resource "azurerm_role_assignment" "me_kv_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.me.object_id
}

# Custom role definition for the OpenBao service principal
# Grants only the data-plane permissions needed for auto-unseal
resource "azurerm_role_definition" "kv_sp_farm" {
  name        = "Key OpenBao SP"
  scope       = data.azurerm_subscription.current.id
  description = "Minimal role for OpenBao auto-unseal (wrap/unwrap/get key)."

  permissions {
    actions          = []
    not_actions      = []
    data_actions     = [
      "Microsoft.KeyVault/vaults/keys/read",
      "Microsoft.KeyVault/vaults/keys/wrap/action",
      "Microsoft.KeyVault/vaults/keys/unwrap/action"
    ]
    not_data_actions = []
  }

  assignable_scopes = [data.azurerm_subscription.current.id]
}

# Assign the custom role to the OpenBao service principal
resource "azurerm_role_assignment" "sp_kv_farm" {
  scope                = azurerm_key_vault.kv.id
  role_definition_id   = azurerm_role_definition.kv_sp_farm.role_definition_resource_id
  principal_id         = azuread_service_principal.openbao_sp.object_id
  principal_type       = "ServicePrincipal"

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_role_definition.kv_sp_farm,
    azuread_service_principal.openbao_sp,
  ]
}

# Push the Azure credentials and Key Vault info to K3s as a secret
resource "kubernetes_secret_v1" "auth_azure_kv" {
  metadata {
    name      = "auth-azure-kv"
    namespace = var.k3s_namespace
  }

  type = "Opaque"
  data_wo = {
    AZURE_TENANT_ID      = data.azurerm_client_config.me.tenant_id
    AZURE_CLIENT_ID      = azuread_application_registration.openbao.client_id
    AZURE_CLIENT_SECRET  = azuread_application_password.openbao_sp_secret.value
    AZURE_KEY_VAULT_NAME = azurerm_key_vault.kv.name
    AZURE_KEY_NAME       = azurerm_key_vault_key.openbao_unseal.name
  }
  data_wo_revision = 4

  depends_on = [
    azurerm_role_definition.kv_sp_farm,
    azurerm_role_assignment.sp_kv_farm
  ]
}
