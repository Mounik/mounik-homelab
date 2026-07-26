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

# --- VM Template ---

# --- Réseau ---
variable "gateway" {
  description = "Passerelle par défaut"
  type        = string
  default     = "192.168.1.254"
}

# --- Storage ---
variable "datastore_id" {
  description = "Datastore Proxmox pour les VMs"
  type        = string
  default     = "local-lvm"
}

# --- SSH ---
variable "ssh_public_key" {
  description = "Clé publique SSH"
  type        = string
}
