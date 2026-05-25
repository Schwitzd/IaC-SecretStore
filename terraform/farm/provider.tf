terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    azurerm = {
      source = "hashicorp/azurerm"
    }

    azuread = {
      source = "hashicorp/azuread"
    }

    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "homefarm"
  insecure       = true
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_keys_on_destroy = true
      recover_soft_deleted_keys          = true
    }
  }

  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "vault" {
  address          = var.openbao_address
  token            = var.openbao_token
  skip_child_token = true
}
