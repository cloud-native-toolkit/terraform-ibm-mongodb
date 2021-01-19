# Databases for MongoDB terraform module

This terraform module will provision an instance of MongoDB into an account. If the key protect values are provided then it will provision the instance using
the provided encryption key. 

## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform - v12
- kubectl

### Terraform providers

- IBM Cloud provider >= 1.17.0

## Module dependencies

This module makes use of the output from other modules:

- Cluster - github.com/ibm-garage-cloud/terraform-ibm-container-platform.git

## Example usage

```hcl-terraform
module "dev_infrastructure_mongodb" {
  source = "github.com/ibm-garage-cloud/terraform-ibm-mongodb.git?ref=v1.0.0"

  resource_group_name = module.dev_cluster.resource_group_name
  resource_location   = module.dev_cluster.region
  name_prefix         = var.name_prefix
  tags                = [module.dev_cluster.tag]
  key-protect-region  = var.key-protect-region
  key-protect-name    = var.key-protect-name
  key-protect-key     = var.key-protect-key
  authorize-kms       = var.authorize-kms == "true"
}
```

