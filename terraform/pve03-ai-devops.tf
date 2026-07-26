# =============================================================================
# VMs pve03 - AI & DevOps Lab - k3s Cluster - mounik-homelab
# =============================================================================

variable "pve03_node" {
  type    = string
  default = "pve03"
}

# --- k3s Node 02 (server/agent) ---
# Deuxième nœud du cluster Kubernetes

module "k3s_node02" {
  source = "./modules/vm"

  vm_name        = "k3s-node02"
  vm_id          = 300
  node_name      = var.pve03_node
  template_name  = var.template_name
  cpu_cores      = 4
  memory_mb      = 24576  # 24 Go pour K8s
  disk_gb        = 100
  ip_address     = "192.168.20.210"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "k8s;wazuh;n8n"
  description    = "k3s Node 02 - Wazuh, n8n, monitoring"

  disks = [
    { size = "100", datastore_id = var.datastore_id }
  ]
}

# --- VMs IA (restent en Docker) ---
# Ollama a besoin d'accès direct aux ressources

module "ollama" {
  source = "./modules/vm"

  vm_name        = "ollama"
  vm_id          = 310
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
  vm_id          = 311
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
  vm_id          = 312
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
  vm_id          = 313
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
  vm_id          = 314
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
