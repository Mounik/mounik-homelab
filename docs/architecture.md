# Architecture - mounik-homelab

## Vue d'ensemble

Plateforme personnelle auto-hébergée basée sur un cluster Proxmox à 3 nœuds, déployée automatiquement via OpenTofu et configurée avec Ansible.

## Architecture physique

### Cluster Proxmox

| Nœud  | CPU              | RAM  | Stockage                  | Rôle                 |
|-------|------------------|------|---------------------------|----------------------|
| pve01 | Intel i5-12600H  | 16 Go| NVMe 500 Go + SSD 1 To   | Infrastructure Core  |
| pve02 | Intel i5-12600H  | 32 Go| NVMe 500 Go + SSD 1 To   | Personal Cloud       |
| pve03 | Intel i5-12600H  | 32 Go| NVMe 500 Go + SSD 1 To   | AI & DevOps Lab      |

### Répartition des services

#### pve01 — Infrastructure Core (16 Go RAM)

Services critiques de la plateforme :

| Service          | VM ID | IP               | RAM   | Description                    |
|------------------|-------|------------------|-------|--------------------------------|
| traefik          | 100   | 192.168.20.100   | 2 Go  | Reverse proxy                  |
| monitoring       | 101   | 192.168.20.101   | 4 Go  | Prometheus + Grafana + Loki    |
| authentik        | 102   | 192.168.20.102   | 2 Go  | SSO & authentification         |
| vaultwarden      | 103   | 192.168.20.103   | 1 Go  | Gestionnaire de mots de passe  |
| cloudflare-tunnel| 104   | 192.168.20.104   | 512 Mo| Accès externe                  |

#### pve02 — Personal Cloud (32 Go RAM)

Services utilisés au quotidien :

| Service          | VM ID | IP               | RAM   | Description                    |
|------------------|-------|------------------|-------|--------------------------------|
| paperless        | 200   | 192.168.30.100   | 4 Go  | Documents administratifs       |
| immich           | 201   | 192.168.30.101   | 4 Go  | Photos personnelles            |
| nextcloud        | 202   | 192.168.30.102   | 4 Go  | Cloud personnel                |
| mealie           | 203   | 192.168.30.103   | 1 Go  | Recettes                       |
| actual-budget    | 204   | 192.168.30.104   | 1 Go  | Gestion financière             |
| home-assistant   | 205   | 192.168.30.105   | 2 Go  | Domotique                      |
| plex             | 206   | 192.168.30.106   | 4 Go  | Média serveur                  |

#### pve03 — AI & DevOps Lab (32 Go RAM)

Expérimentation et développement :

| Service          | VM ID | IP               | RAM   | Description                    |
|------------------|-------|------------------|-------|--------------------------------|
| ollama           | 300   | 192.168.40.100   | 8 Go  | API IA (modèles cloud)         |
| open-webui       | 301   | 192.168.40.101   | 4 Go  | Interface IA                   |
| qdrant           | 302   | 192.168.40.102   | 4 Go  | Base vectorielle               |
| langgraph        | 303   | 192.168.40.103   | 4 Go  | Agents IA                      |
| n8n              | 304   | 192.168.40.104   | 2 Go  | Automatisation                 |
| gitea            | 310   | 192.168.20.200   | 2 Go  | Forge logicielle               |
| harbor           | 311   | 192.168.20.201   | 4 Go  | Registry Docker                |
| wazuh            | 312   | 192.168.20.202   | 4 Go  | SIEM & sécurité                |

## Architecture logicielle

### Pipeline de déploiement

```
Code source (Git)
    |
    v
OpenTofu (création VMs sur Proxmox)
    |
    v
Cloud-init (OS + Docker + user)
    |
    v
Ansible (configuration système + services)
    |
    v
Docker Compose (applications)
```

### Stack technique

| Couche           | Technologies                                    |
|------------------|------------------------------------------------|
| Virtualisation   | Proxmox VE, VMs Debian 13, LXC                 |
| IaC              | OpenTofu, provider bpg/proxmox                 |
| Configuration    | Ansible, rôles custom                           |
| Orchestration    | Docker, Docker Compose                          |
| Reverse Proxy    | Traefik v3                                      |
| Auth             | TinyAuth (Phase 1), Authentik (Phase 2)         |
| Sécurité         | CrowdSec (IDS/IPS + WAF), nftables, Trivy       |
| Monitoring       | Prometheus, Grafana, Loki, Alertmanager          |
| IA               | Ollama, OpenWebUI, Qdrant, LangGraph, n8n       |
| DNS              | Cloudflare DNS + Cloudflare Tunnel              |

### Diagramme d'architecture

```
                        INTERNET
                            |
                   Cloudflare Tunnel
                            |
                         Traefik
                            |
                     TinyAuth (auth)
                     CrowdSec (IDS/IPS)
                            |
            +---------------+---------------+
            |               |               |
       Applications        IA          DevSecOps
            |               |               |
      Paperless-ngx    OpenWebUI          Git
      Immich           Ollama         CI/CD
      Vaultwarden      Qdrant         Security
      Mealie           LangGraph      Monitoring
      Nextcloud        n8n
      Obsidian (2nd Brain)
```

## Déploiement

### Prérequis

- Proxmox VE installé sur les 3 nœuds
- Template Debian 13 créé (VM ID 9000)
- Clé SSH déployée sur chaque nœud
- OpenTofu et Ansible installés sur la machine de contrôle

### Commandes

```bash
# Déploiement complet
./scripts/deploy.sh deploy

# Ou étape par étape
./scripts/deploy.sh init      # Initialiser OpenTofu
./scripts/deploy.sh plan      # Planifier
./scripts/deploy.sh apply     # Créer les VMs
./scripts/deploy.sh configure # Configurer avec Ansible
```

## Sauvegarde

### Règle 3-2-1

- **3** copies des données
- **2** supports différents
- **1** copie externe (disque dur physique)

### Flux

```
VM Proxmox → Proxmox Backup Server → Disque dur externe
```

## Maintenance

### Mises à jour

- **Debian** : `unattended-upgrades` (correctifs de sécurité automatiques)
- **Docker** : manuel, via Ansible
- **Services** : manuel, via `docker compose pull && docker compose up -d`

### Monitoring

Prometheus collecte les métriques de :
- Proxmox (exporter)
- VMs (node_exporter)
- Containers (cAdvisor)
- Services (endpoints custom)

Grafana affiche les dashboards. Alertmanager envoie les alertes sur Discord/Email.
