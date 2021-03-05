provider "ibm" {
  version = ">= 1.17.0"
  region = local.key-protect-region
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
  byok-enabled       = var.key-protect-name != "" && var.key-protect-key != ""
  parameters         = local.byok-enabled ? {
    disk_encryption_key_crn = data.ibm_kms_key.key[0].keys[0].crn
  } : {}
}

resource "null_resource" "print_kp_guid" {
  count = local.byok-enabled ? 1 : 0

  provisioner "local-exec" {
    command = "echo \"BYOK enabled: ${local.byok-enabled}, key-protect: ${data.ibm_resource_instance.kp_instance[0].guid}\""
  }
}

resource "null_resource" "print-params" {
  provisioner "local-exec" {
    command = "echo \"parameters: ${jsonencode(local.parameters)}\""
  }
}

data "ibm_resource_instance" "kp_instance" {
  count = local.byok-enabled ? 1 : 0

  name = var.key-protect-name
  location = local.key-protect-region
  resource_group_id = data.ibm_resource_group.kp_resource_group.id
}

data "ibm_kms_key" "key" {
  count = local.byok-enabled ? 1 : 0

  instance_id = data.ibm_resource_instance.kp_instance[0].guid
  key_name    = var.key-protect-key
}

resource "ibm_iam_authorization_policy" "policy" {
  count = local.byok-enabled && var.authorize-kms ? 1 : 0

  source_service_name         = local.service
  target_service_name         = "kms"
  roles                       = ["Reader"]
}

resource "ibm_resource_instance" "mongodb_instance" {
  depends_on = [ibm_iam_authorization_policy.policy]

  name                 = local.name
  service              = local.service
  plan                 = var.plan
  location             = var.resource_location
  resource_group_id    = data.ibm_resource_group.resource_group.id
  tags                 = var.tags

  parameters = local.parameters

  timeouts {
    create = "60m"
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
