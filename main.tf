provider "ibm" {
  version = ">= 1.17.0"
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group_name
}

data "ibm_resource_group" "kp_resource_group" {
  name = local.key-protect-resource-group
}

locals {
  service            = "databases-for-mongodb"
  name_prefix        = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  name               = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-mongodb"
  key-protect-resource-group = var.key-protect-resource-group != "" ? var.key-protect-resource-group : var.resource_group_name
  key-protect-region = var.key-protect-region != "" ? var.key-protect-region : var.resource_location
  byok-enabled       = var.key-protect-name != "" && var.key-protect-key-id != ""
  parameters         = local.byok-enabled ? {
    key_protect_instance = data.ibm_resource_instance.kp_instance[0].guid
    key_protect_key      = var.key-protect-key-id
  } : {}
}

resource "null_resource" "print-params" {
  provisioner "local-exec" {
    command = "echo \"BYOK enabled: ${local.byok-enabled}, parameters: ${jsonencode(local.parameters)}\""
  }
}

data "ibm_resource_instance" "kp_instance" {
  count = local.byok-enabled ? 1 : 0

  name = var.key-protect-name
  location = local.key-protect-region
  resource_group_id = data.ibm_resource_group.kp_resource_group.id
}

resource "ibm_resource_instance" "mongodb_instance" {
  name                 = local.name
  service              = local.service
  plan                 = var.plan
  location             = var.resource_location
  resource_group_id    = data.ibm_resource_group.resource_group.id
  tags                 = var.tags

  parameters = local.parameters

  timeouts {
    create = "30m"
    update = "15m"
    delete = "15m"
  }
}

data "ibm_resource_instance" "mongodb_instance" {
  depends_on        = [ibm_resource_instance.mongodb_instance]

  name              = local.name
  resource_group_id = data.ibm_resource_group.resource_group.id
  location          = var.resource_location
  service           = local.service
}

resource "ibm_resource_key" "mongodb_key" {
  name                 = "${local.name}-key"
  role                 = var.role
  resource_instance_id = data.ibm_resource_instance.mongodb_instance.id

  //User can increase timeouts
  timeouts {
    create = "15m"
    delete = "15m"
  }
}
