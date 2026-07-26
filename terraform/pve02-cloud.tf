# =============================================================================
# VMs pve02 - Personal Cloud - mounik-homelab
# =============================================================================

variable "pve02_node" {
  type    = string
  default = "pve02"
}

# --- VMs Services Personnels ---

module "paperless" {
  source = "./modules/vm"

  vm_name        = "paperless"
  vm_id          = 200
  node_name      = var.pve02_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 4096
  disk_gb        = 50
  ip_address     = "192.168.30.100"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "app;documents"
  description    = "Paperless-ngx - Documents administratifs"
}

module "immich" {
  source = "./modules/vm"

  vm_name        = "immich"
  vm_id          = 201
  node_name      = var.pve02_node
  template_name  = var.template_name
  cpu_cores      = 4
  memory_mb      = 4096
  disk_gb        = 80
  ip_address     = "192.168.30.101"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "app;photos"
  description    = "Immich - Photos personnelles"
}

module "nextcloud" {
  source = "./modules/vm"

  vm_name        = "nextcloud"
  vm_id          = 202
  node_name      = var.pve02_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 4096
  disk_gb        = 100
  ip_address     = "192.168.30.102"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "app;cloud"
  description    = "Nextcloud - Cloud personnel"

  disks = [
    { size = "100", datastore_id = var.datastore_id }
  ]
}

module "mealie" {
  source = "./modules/vm"

  vm_name        = "mealie"
  vm_id          = 203
  node_name      = var.pve02_node
  template_name  = var.template_name
  cpu_cores      = 1
  memory_mb      = 1024
  disk_gb        = 10
  ip_address     = "192.168.30.103"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "app;recipes"
  description    = "Mealie - Recettes"
}

module "actual_budget" {
  source = "./modules/vm"

  vm_name        = "actual-budget"
  vm_id          = 204
  node_name      = var.pve02_node
  template_name  = var.template_name
  cpu_cores      = 1
  memory_mb      = 1024
  disk_gb        = 10
  ip_address     = "192.168.30.104"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "app;finance"
  description    = "Actual Budget - Gestion financière"
}

module "home_assistant" {
  source = "./modules/vm"

  vm_name        = "home-assistant"
  vm_id          = 205
  node_name      = var.pve02_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 2048
  disk_gb        = 20
  ip_address     = "192.168.30.105"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "app;iot"
  description    = "Home Assistant - Domotique"
}

module "plex" {
  source = "./modules/vm"

  vm_name        = "plex"
  vm_id          = 206
  node_name      = var.pve02_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 4096
  disk_gb        = 30
  ip_address     = "192.168.30.106"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "app;media"
  description    = "Plex - Média serveur"
}
