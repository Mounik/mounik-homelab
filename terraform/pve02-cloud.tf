# =============================================================================
# VMs pve02 - Personal Cloud + k3s Node - mounik-homelab
# =============================================================================

variable "pve02_node" {
  type    = string
  default = "pve02"
}

# --- k3s Node 01 (server/agent) ---
# VM principale pour le cluster Kubernetes
# 24 Go RAM dédiée au cluster (restant pour apps Docker)

module "k3s_node01" {
  source = "./modules/vm"

  vm_name        = "k3s-node01"
  vm_id          = 200
  node_name      = var.pve02_node
  template_name  = var.template_name
  cpu_cores      = 4
  memory_mb      = 24576  # 24 Go pour K8s
  disk_gb        = 100
  ip_address     = "192.168.20.200"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "k8s;gitlab;argocd;harbor"
  description    = "k3s Node 01 - GitLab CE, ArgoCD, Harbor"

  disks = [
    { size = "100", datastore_id = var.datastore_id }
  ]
}

# --- Apps Docker restantes sur pve02 ---
# Services qui restent en Docker Compose (pas dans K8s)

module "paperless" {
  source = "./modules/vm"

  vm_name        = "paperless"
  vm_id          = 210
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
  vm_id          = 211
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
  vm_id          = 212
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
}

module "mealie" {
  source = "./modules/vm"

  vm_name        = "mealie"
  vm_id          = 213
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
  vm_id          = 214
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
  vm_id          = 215
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
  vm_id          = 216
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
