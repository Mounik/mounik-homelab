# =============================================================================
# Outputs - mounik-homelab
# =============================================================================

# --- IP des VMs ---
output "vm_ips" {
  description = "Adresses IP de toutes les VMs"
  value = {
    # pve01
    traefik             = module.traefik.ip_address
    monitoring          = module.monitoring.ip_address
    authentik           = module.authentik.ip_address
    vaultwarden         = module.vaultwarden.ip_address
    cloudflare-tunnel   = module.cloudflare_tunnel.ip_address
    # pve02
    paperless           = module.paperless.ip_address
    immich              = module.immich.ip_address
    nextcloud           = module.nextcloud.ip_address
    mealie              = module.mealie.ip_address
    actual-budget       = module.actual_budget.ip_address
    home-assistant      = module.home_assistant.ip_address
    plex                = module.plex.ip_address
    # pve03
    ollama              = module.ollama.ip_address
    open-webui          = module.openwebui.ip_address
    qdrant              = module.qdrant.ip_address
    langgraph           = module.langgraph.ip_address
    n8n                 = module.n8n.ip_address
    gitea               = module.gitea.ip_address
    harbor              = module.harbor.ip_address
    wazuh               = module.wazuh.ip_address
  }
}

# --- VM IDs ---
output "vm_ids" {
  description = "IDs de toutes les VMs"
  value = {
    traefik           = module.traefik.vm_id
    monitoring        = module.monitoring.vm_id
    authentik         = module.authentik.vm_id
    vaultwarden       = module.vaultwarden.vm_id
    cloudflare-tunnel = module.cloudflare_tunnel.vm_id
    paperless         = module.paperless.vm_id
    immich            = module.immich.vm_id
    nextcloud         = module.nextcloud.vm_id
    mealie            = module.mealie.vm_id
    actual-budget     = module.actual_budget.vm_id
    home-assistant    = module.home_assistant.vm_id
    plex              = module.plex.vm_id
    ollama            = module.ollama.vm_id
    open-webui        = module.openwebui.vm_id
    qdrant            = module.qdrant.vm_id
    langgraph         = module.langgraph.vm_id
    n8n               = module.n8n.vm_id
    gitea             = module.gitea.vm_id
    harbor            = module.harbor.vm_id
    wazuh             = module.wazuh.vm_id
  }
}

# --- Inventaire Ansible ---
output "ansible_inventory" {
  description = "Chemin vers l'inventaire Ansible généré"
  value       = local_file.ansible_inventory.filename
}
