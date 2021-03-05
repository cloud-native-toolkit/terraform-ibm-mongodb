module "dev_tools_mongodb" {
  source = "./module"

  resource_group_name = var.resource_group_name
  resource_location   = var.region
  name_prefix         = "${var.name_prefix}_2"
  key-protect-region  = var.key-protect-region
  key-protect-name    = var.key-protect-name
  key-protect-key     = var.key-protect-key
  authorize-kms       = var.authorize-kms == "true"
}
