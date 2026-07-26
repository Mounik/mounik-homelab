# =============================================================================
# Module VM - mounik-homelab
# Crée une VM Proxmox à partir d'un template avec cloud-init
# =============================================================================

# --- Variables ---
variable "vm_name" {
  description = "Nom de la VM"
  type        = string
}

variable "vm_id" {
  description = "ID unique de la VM dans Proxmox"
  type        = number
}

variable "node_name" {
  description = "Nœud Proxmox cible"
  type        = string
}

variable "template_vm_id" {
  description = "ID du template à cloner"
  type        = number
  default     = 9000
}

variable "cpu_cores" {
  description = "Nombre de cœurs CPU"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "RAM en Mo"
  type        = number
  default     = 2048
}

variable "disk_gb" {
  description = "Taille du disque en Go"
  type        = number
  default     = 30
}

variable "ip_address" {
  description = "Adresse IP statique (ex: 192.168.20.100)"
  type        = string
}

variable "gateway" {
  description = "Passerelle réseau"
  type        = string
}

variable "ssh_public_key" {
  description = "Clé publique SSH"
  type        = string
}

variable "datastore_id" {
  description = "Datastore Proxmox"
  type        = string
  default     = "local-lvm"
}

variable "disks" {
  description = "Liste des disques"
  type = list(object({
    size    = string
    datastore_id = string
  }))
  default = []
}

variable "tags" {
  description = "Tags Proxmox (sep: ;)"
  type        = string
  default     = ""
}

variable "description" {
  description = "Description de la VM"
  type        = string
  default     = ""
}

# --- Cloud-Init Config ---
data "cloudinit_config" "vm_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/../templates/debian-cloud-init.yaml.tpl", {
      ip_address     = var.ip_address
      gateway        = var.gateway
      dns_servers    = ["1.1.1.1", "1.0.0.1"]
      ssh_public_key = var.ssh_public_key
    })
  }
}

# --- Resource VM ---
resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_name
  vm_id     = var.vm_id
  node_name = var.node_name
  description = var.description

  tags = var.tags

  # Clonage du template
  clone {
    vm_id     = var.template_vm_id
    node_name = var.node_name
    full      = true
    retries   = 3
  }

  # Cloud-init
  initialization {
    datastore_id = var.datastore_id
    user_data_file_id = data.cloudinit_config.vm_config.id
  }

  # CPU
  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  # Mémoire
  memory {
    dedicated = var.memory_mb
  }

  # Disques
  disk {
    datastore_id = var.datastore_id
    size         = var.disk_gb
    interface    = "scsi0"
  }

  # Disques supplémentaires
  dynamic "disk" {
    for_each = var.disks
    content {
      datastore_id = disk.value.datastore_id
      size         = disk.value.size
      interface    = "scsi${disk.key + 1}"
    }
  }

  # Network - Bridge principal
  network_device {
    bridge     = "vmbr0"
    model      = "virtio"
  }

  # BIOS
  bios = "seabios"

  # Agent QEMU
  agent {
    enabled = true
  }

  # Protection anti-suppression
  protection {
    destroy = false
    stop    = false
  }

  # Machine type
  machine_type = "q35"

  # Timeout
  timeouts {
    create = "15m"
    update = "10m"
    delete = "5m"
  }
}

# --- Outputs ---
output "vm_id" {
  value = proxmox_virtual_environment_vm.vm.vm_id
}

output "vm_name" {
  value = proxmox_virtual_environment_vm.vm.name
}

output "ip_address" {
  value = var.ip_address
}

output "node_name" {
  value = var.node_name
}
