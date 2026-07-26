# =============================================================================
# VMs pve01 - Infrastructure Core - mounik-homelab
# =============================================================================

# --- Variables locales ---
variable "ssh_public_key" {
  type = string
}

variable "pve01_node" {
  type    = string
  default = "pve01"
}

# --- VMs Infrastructure ---

module "traefik" {
  source = "./modules/vm"

  vm_name        = "traefik"
  vm_id          = 100
  node_name      = var.pve01_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 2048
  disk_gb        = 20
  ip_address     = "192.168.20.100"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "infra;reverse-proxy"
  description    = "Traefik v3 - Reverse proxy"
}

module "monitoring" {
  source = "./modules/vm"

  vm_name        = "monitoring"
  vm_id          = 101
  node_name      = var.pve01_node
  template_name  = var.template_name
  cpu_cores      = 4
  memory_mb      = 4096
  disk_gb        = 50
  ip_address     = "192.168.20.101"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "infra;monitoring"
  description    = "Prometheus + Grafana + Loki + Alertmanager"

  disks = [
    { size = "50", datastore_id = var.datastore_id }
  ]
}

module "authentik" {
  source = "./modules/vm"

  vm_name        = "authentik"
  vm_id          = 102
  node_name      = var.pve01_node
  template_name  = var.template_name
  cpu_cores      = 2
  memory_mb      = 2048
  disk_gb        = 20
  ip_address     = "192.168.20.102"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "infra;sso"
  description    = "Authentik - SSO & authentification"
}

module "vaultwarden" {
  source = "./modules/vm"

  vm_name        = "vaultwarden"
  vm_id          = 103
  node_name      = var.pve01_node
  template_name  = var.template_name
  cpu_cores      = 1
  memory_mb      = 1024
  disk_gb        = 10
  ip_address     = "192.168.20.103"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "infra;secrets"
  description    = "Vaultwarden - Gestionnaire de mots de passe"
}

module "cloudflare_tunnel" {
  source = "./modules/vm"

  vm_name        = "cloudflare-tunnel"
  vm_id          = 104
  node_name      = var.pve01_node
  template_name  = var.template_name
  cpu_cores      = 1
  memory_mb      = 512
  disk_gb        = 10
  ip_address     = "192.168.20.104"
  gateway        = var.gateway
  ssh_public_key = var.ssh_public_key
  datastore_id   = var.datastore_id
  tags           = "infra;network"
  description    = "Cloudflare Tunnel - Accès externe"
}
