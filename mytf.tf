module "resource_group" {
    source = "./modules/resource_group"
    resource_group_name = "${var.resource_group_name}"
    location = "${var.location}"
    tags = "${var.tags}"
}

module "network" {
  source = "./modules/network"
  name = "${var.name}"
  resource_group_name = "${module.resource_group.name}"
  location = "${var.location}"
  cidr = "${var.cluster_cidr}"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${var.name}"
  location            = "${var.location}"
  resource_group_name = "${module.resource_group.name}"
  dns_prefix          = "${var.name}-dns"

  default_node_pool {
    name            = "${var.agent_pool_name}"
    node_count      = "${var.agent_count}"
    vm_size         = "${var.vm_size}"
    os_disk_size_gb = "${var.os_disk_size}"
    type = "VirtualMachineScaleSets"
    vnet_subnet_id = "${module.network.subnet_id}"
  }

  service_principal {
    client_id     = "${var.kubernetes_client_id}"
    client_secret = "${var.kubernetes_client_secret}"
  }

  role_based_access_control {
    enabled = true
  }

  tags = "${var.tags}"
    
}



