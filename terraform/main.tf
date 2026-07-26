# =============================================================================
# Main - mounik-homelab
# Point d'entrée OpenTofu - orchestre le déploiement
# =============================================================================

# --- Locals ---
locals {
  # Map de toutes les VMs pour Ansible
  all_vms = merge(
    {
      # pve01 - Infrastructure
      "traefik" = { ip = module.traefik.ip_address, node = "pve01", role = "infra" }
      "monitoring" = { ip = module.monitoring.ip_address, node = "pve01", role = "infra" }
      "authentik" = { ip = module.authentik.ip_address, node = "pve01", role = "infra" }
      "vaultwarden" = { ip = module.vaultwarden.ip_address, node = "pve01", role = "infra" }
      "cloudflare-tunnel" = { ip = module.cloudflare_tunnel.ip_address, node = "pve01", role = "infra" }
    },
    {
      # pve02 - Personal Cloud
      "paperless" = { ip = module.paperless.ip_address, node = "pve02", role = "app" }
      "immich" = { ip = module.immich.ip_address, node = "pve02", role = "app" }
      "nextcloud" = { ip = module.nextcloud.ip_address, node = "pve02", role = "app" }
      "mealie" = { ip = module.mealie.ip_address, node = "pve02", role = "app" }
      "actual-budget" = { ip = module.actual_budget.ip_address, node = "pve02", role = "app" }
      "home-assistant" = { ip = module.home_assistant.ip_address, node = "pve02", role = "app" }
      "plex" = { ip = module.plex.ip_address, node = "pve02", role = "app" }
    },
    {
      # pve03 - AI & DevOps
      "ollama" = { ip = module.ollama.ip_address, node = "pve03", role = "ai" }
      "open-webui" = { ip = module.openwebui.ip_address, node = "pve03", role = "ai" }
      "qdrant" = { ip = module.qdrant.ip_address, node = "pve03", role = "ai" }
      "langgraph" = { ip = module.langgraph.ip_address, node = "pve03", role = "ai" }
      "n8n" = { ip = module.n8n.ip_address, node = "pve03", role = "ai" }
      "gitea" = { ip = module.gitea.ip_address, node = "pve03", role = "devops" }
      "harbor" = { ip = module.harbor.ip_address, node = "pve03", role = "devops" }
      "wazuh" = { ip = module.wazuh.ip_address, node = "pve03", role = "devops" }
    }
  )
}

# --- Générer l'inventaire Ansible ---
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory-generated.yml"
  content = templatefile("${path.module}/templates/inventory.yml.tpl", {
    vms = local.all_vms
  })
}
