terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "vault" {
  address          = var.openbao_address
  token            = var.openbao_token
  skip_child_token = true
}
