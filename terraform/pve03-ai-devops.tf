# =============================================================================
# VMs pve03 - AI & DevOps Lab - mounik-homelab
# =============================================================================

variable "pve03_node" {
  type    = string
  default = "pve03"
}

# --- VMs IA ---

module "ollama" {
  source = "./modules/vm"

  vm_name        = "ollama"
  vm_id          = 300
  node_name      = var.pve03_node
  template_name  = var.template_name
  cpu_cores      = 4
  memory_mb      = 8192
  disk_gb        = 50
  ip_address     = "192.168.40.100"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "ai;llm"
  description    = "Ollama - Modèles IA (cloud API)"
}

module "openwebui" {
  source = "./modules/vm"

  vm_name        = "open-webui"
  vm_id          = 301
  node_name      = var.pve03_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 4096
  disk_gb        = 30
  ip_address     = "192.168.40.101"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "ai;ui"
  description    = "OpenWebUI - Interface IA"
}

module "qdrant" {
  source = "./modules/vm"

  vm_name        = "qdrant"
  vm_id          = 302
  node_name      = var.pve03_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 4096
  disk_gb        = 30
  ip_address     = "192.168.40.102"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "ai;vector-db"
  description    = "Qdrant - Base vectorielle"
}

module "langgraph" {
  source = "./modules/vm"

  vm_name        = "langgraph"
  vm_id          = 303
  node_name      = var.pve03_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 4096
  disk_gb        = 20
  ip_address     = "192.168.40.103"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "ai;agents"
  description    = "LangGraph - Agents IA"
}

module "n8n" {
  source = "./modules/vm"

  vm_name        = "n8n"
  vm_id          = 304
  node_name      = var.pve03_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 2048
  disk_gb        = 20
  ip_address     = "192.168.40.104"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "ai;automation"
  description    = "n8n - Automatisation"
}

# --- VMs DevSecOps ---

module "gitea" {
  source = "./modules/vm"

  vm_name        = "gitea"
  vm_id          = 310
  node_name      = var.pve03_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 2048
  disk_gb        = 30
  ip_address     = "192.168.20.200"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "devops;git"
  description    = "Gitea - Forge logicielle"
}

module "harbor" {
  source = "./modules/vm"

  vm_name        = "harbor"
  vm_id          = 311
  node_name      = var.pve03_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 4096
  disk_gb        = 50
  ip_address     = "192.168.20.201"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "devops;registry"
  description    = "Harbor - Registry Docker"

  disks = [
    { size = "50", datastore_id = var.datastore_id }
  ]
}

module "wazuh" {
  source = "./modules/vm"

  vm_name        = "wazuh"
  vm_id          = 312
  node_name      = var.pve03_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 4096
  disk_gb        = 50
  ip_address     = "192.168.20.202"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "devops;security;siem"
  description    = "Wazuh - SIEM & sécurité"
}
