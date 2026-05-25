terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "vault" {
  skip_child_token = true
}
