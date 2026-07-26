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

- [Architecture](architecture.md) — Vue d'ensemble du cluster et des choix techniques
- [Réseau](network.md) — VLANs, plan IP, sous-domaines, firewall
- [Services](services.md) — Guide complet de chaque service
- [Sécurité](security.md) — Les 7 couches de protection
- [Disaster Recovery](disaster-recovery.md) — Sauvegardes et restauration
- [Glossaire](glossary.md) — Termes techniques expliqués

## Architecture rapide

```
Internet → Cloudflare Tunnel → Traefik → TinyAuth → Services
                                                 → CrowdSec (IDS/IPS)
```

| Nœud  | Rôle | RAM | Services |
|-------|------|-----|----------|
| pve01 | Infrastructure Core | 16 Go | Traefik, Monitoring, Vaultwarden |
| pve02 | Personal Cloud + k3s | 32 Go | GitLab, ArgoCD, Paperless, Immich |
| pve03 | AI + k3s | 32 Go | Ollama, OpenWebUI, JobSync, Wazuh |

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
| Kubernetes | k3s + Longhorn + MetalLB |
| Reverse Proxy | Traefik v3 |
| Auth | TinyAuth → Authentik |
| IDS/IPS | CrowdSec |
| GitOps | ArgoCD |
| CI/CD | GitLab CI |
| Registry | Harbor |
| Monitoring | Prometheus + Grafana |
| IA | Ollama + OpenWebUI + LangGraph |
