# =============================================================================
# Variables Proxmox - mounik-homelab
# =============================================================================

# --- Connexion Proxmox ---
variable "proxmox_endpoint" {
  description = "URL de l'API Proxmox (ex: https://192.168.1.20:8006)"
  type        = string
}

variable "proxmox_username" {
  description = "Utilisateur Proxmox (ex: root@pam)"
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Mot de passe Proxmox"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Ignorer les erreurs SSL (self-signed certs)"
  type        = bool
  default     = true
}

# --- Proxmox Nodes ---
variable "pve_nodes" {
  description = "Map des nœuds Proxmox"
  type = map(object({
    node_name = string
    ip_suffix = string
  }))
  default = {
    pve01 = { node_name = "pve01", ip_suffix = "20" }
    pve02 = { node_name = "pve02", ip_suffix = "21" }
    pve03 = { node_name = "pve03", ip_suffix = "22" }
  }
}

# --- VM Template ---
variable "template_name" {
  description = "Nom du template Debian 13 dans Proxmox"
  type        = string
  default     = "debian-13-template"
}

variable "template_vm_id" {
  description = "ID du template Debian 13"
  type        = number
  default     = 9000
}

# --- Réseau ---
variable "gateway" {
  description = "Passerelle par défaut"
  type        = string
  default     = "192.168.1.254"
}

variable "dns_servers" {
  description = "Serveurs DNS"
  type        = list(string)
  default     = ["1.1.1.1", "1.0.0.1"]
}

# --- Storage ---
variable "datastore_id" {
  description = "Datastore Proxmox pour les VMs"
  type        = string
  default     = "local-lvm"
}

variable "iso_datastore_id" {
  description = "Datastore pour les ISOs"
  type        = string
  default     = "local"
}

# --- k3s Cluster ---
variable "k3s_version" {
  description = "Version de k3s"
  type        = string
  default     = "v1.31.4+k3s1"
}

variable "k3s_token" {
  description = "Token secret pour le cluster k3s"
  type        = string
  sensitive   = true
}

variable "k3s_server_ip" {
  description = "IP du premier nœud k3s (server)"
  type        = string
  default     = "192.168.20.200"
}

variable "k3s_additionalSANs" {
  description = "SANs supplémentaires pour l'API server"
  type        = list(string)
  default     = ["k3s.mounik.ovh"]
}

variable "ssh_public_key" {
  description = "Clé publique SSH"
  type        = string
}
