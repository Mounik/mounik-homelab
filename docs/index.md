# mounik-homelab

Plateforme personnelle auto-hébergée — un environnement cloud domestique pensé comme un vrai datacenter.

## Ce que ce projet démontre

| Domaine | Compétences |
|---------|-------------|
| **IaC** | OpenTofu, Ansible, Terraform |
| **Virtualisation** | Proxmox VE, VMs, LXC |
| **Réseau** | VLANs, nftables, Cloudflare Tunnel |
| **Sécurité** | CrowdSec, TinyAuth, Trivy, Wazuh |
| **Monitoring** | Prometheus, Grafana, Loki |
| **DevOps** | Docker, CI/CD, GitOps |
| **IA** | Ollama, OpenWebUI, LangGraph, n8n |

## Documentation

- [Architecture](architecture.md) — Vue d'ensemble du cluster et des services
- [Réseau](network.md) — VLANs, plan IP, sous-domaines
- [Sécurité](security.md) — CrowdSec, authentification, firewall
- [Disaster Recovery](disaster-recovery.md) — Sauvegardes et restauration

## Architecture rapide

```
Internet → Cloudflare Tunnel → Traefik → TinyAuth → Services
                                                 → CrowdSec (IDS/IPS)
```

| Nœud  | Rôle | RAM | VMs |
|-------|------|-----|-----|
| pve01 | Infrastructure Core | 16 Go | Traefik, Monitoring, Auth, Vaultwarden |
| pve02 | Personal Cloud | 32 Go | Paperless, Immich, Nextcloud, Mealie |
| pve03 | AI & DevOps Lab | 32 Go | Ollama, OpenWebUI, Gitea, Wazuh |

## Déploiement

```bash
# Prérequis
# - Proxmox VE sur les 3 nœuds
# - Template Debian 13 (VM ID 9000)
# - OpenTofu + Ansible sur la machine de contrôle

# Déploiement complet
./scripts/deploy.sh deploy
```

## Stack technique

| Couche | Technologie |
|--------|-------------|
| Virtualisation | Proxmox VE |
| IaC | OpenTofu |
| Configuration | Ansible |
| Conteneurs | Docker |
| Reverse Proxy | Traefik v3 |
| Auth | TinyAuth → Authentik |
| IDS/IPS | CrowdSec |
| Monitoring | Prometheus + Grafana |
| IA | Ollama + OpenWebUI |
