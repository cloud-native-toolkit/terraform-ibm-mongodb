module "dev_tools_mongodb" {
  source = "./module"

  resource_group_name = var.resource_group_name
  resource_location = var.region
  name_prefix = var.name_prefix
}
