provider "ibm" {
  version = ">= 1.2.1"
}

data "ibm_resource_group" "tools_resource_group" {
  name = var.resource_group_name
}

locals {
  service           = "databases-for-mongodb"
  name_prefix       = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  name              = "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-mongodb"
  resource_location = var.resource_location
}

// AppID - App Authentication
resource "ibm_resource_instance" "mongodb_instance" {
  name              = local.name
  service           = local.service
  plan              = var.plan
  location          = local.resource_location
  resource_group_id = data.ibm_resource_group.tools_resource_group.id
  tags              = var.tags

  timeouts {
    create = "30m"
    update = "15m"
    delete = "15m"
  }
}

data "ibm_resource_instance" "mongodb_instance" {
  depends_on        = [ibm_resource_instance.mongodb_instance]

  name              = local.name
  resource_group_id = data.ibm_resource_group.tools_resource_group.id
  location          = local.resource_location
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

resource "null_resource" "print_config" {
  provisioner "local-exec" {
    command = "echo \"Binding to cluster: ${var.cluster_id}, service id: ${data.ibm_resource_instance.mongodb_instance.id}, key id: ${ibm_resource_key.mongodb_key.id}\""
  }
}

resource "ibm_container_bind_service" "mongodb_service_binding" {
  count = var.namespace_count
  depends_on = [null_resource.print_config]

  cluster_name_id       = var.cluster_id
  service_instance_id   = data.ibm_resource_instance.mongodb_instance.id
  namespace_id          = var.namespaces[count.index]
  resource_group_id     = data.ibm_resource_group.tools_resource_group.id
  key                   = ibm_resource_key.mongodb_key.id

  // The provider (v16.1) is incorrectly registering that these values change each time,
  // this may be removed in the future if this is fixed.
  lifecycle {
    ignore_changes = [id, namespace_id, service_instance_name]
  }
}
