# Architecture - mounik-homelab

## Vue d'ensemble

Plateforme personnelle auto-hébergée basée sur un cluster Proxmox à 3 nœuds avec un cluster Kubernetes (k3s). Déployée automatiquement via OpenTofu et configurée avec Ansible.

## Architecture physique

### Cluster Proxmox

| Nœud  | CPU              | RAM  | Stockage                  | Rôle                 |
|-------|------------------|------|---------------------------|----------------------|
| pve01 | Intel i5-12600H  | 16 Go| NVMe 500 Go + SSD 1 To   | Infrastructure Core  |
| pve02 | Intel i5-12600H  | 32 Go| NVMe 500 Go + SSD 1 To   | Cloud + k3s Node 01  |
| pve03 | Intel i5-12600H  | 32 Go| NVMe 500 Go + SSD 1 To   | AI + k3s Node 02     |

### Répartition des services

#### pve01 — Infrastructure Core (16 Go RAM)

Services critiques en Docker Compose :

| Service          | VM ID | IP               | RAM   | Description                    |
|------------------|-------|------------------|-------|--------------------------------|
| traefik          | 100   | 192.168.20.100   | 2 Go  | Reverse proxy + CrowdSec       |
| monitoring       | 101   | 192.168.20.101   | 4 Go  | Prometheus + Grafana + Loki    |
| vaultwarden      | 103   | 192.168.20.103   | 1 Go  | Gestionnaire de mots de passe  |
| cloudflare-tunnel| 104   | 192.168.20.104   | 512 Mo| Accès externe                  |

#### pve02 — Cloud + k3s Node 01 (32 Go RAM)

| Service          | VM ID | IP               | RAM   | Description                    |
|------------------|-------|------------------|-------|--------------------------------|
| **k3s-node01**   | 200   | 192.168.20.200   | 24 Go | Nœud k3s (server)              |
| paperless        | 210   | 192.168.30.100   | 4 Go  | Documents administratifs       |
| immich           | 211   | 192.168.30.101   | 4 Go  | Photos personnelles            |

#### pve03 — AI + k3s Node 02 (32 Go RAM)

| Service          | VM ID | IP               | RAM   | Description                    |
|------------------|-------|------------------|-------|--------------------------------|
| **k3s-node02**   | 300   | 192.168.20.210   | 24 Go | Nœud k3s (agent)               |
| ollama           | 310   | 192.168.40.100   | 8 Go  | API IA (modèles cloud)         |
| open-webui       | 311   | 192.168.40.101   | 4 Go  | Interface IA                   |

## Architecture Kubernetes (k3s)

### Cluster

```
┌─────────────────────────────────────────────────────────────┐
│                    Cluster k3s                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐    ┌──────────────────┐              │
│  │   k3s-node01     │    │   k3s-node02     │              │
│  │   (Server)       │◄──►│   (Agent)        │              │
│  │   192.168.20.200 │    │   192.168.20.210 │              │
│  └────────┬─────────┘    └────────┬─────────┘              │
│           │                       │                         │
│           ▼                       ▼                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Namespaces Kubernetes                   │   │
│  ├─────────────┬─────────────┬─────────────┬──────────┤   │
│  │   gitlab    │   argocd    │   harbor    │ monitor  │   │
│  │   (CI/CD)   │  (GitOps)   │  (Registry) │ (Prom)   │   │
│  └─────────────┴─────────────┴─────────────┴──────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Storage & Networking                    │   │
│  │  • Longhorn (storage distribué)                     │   │
│  │  • MetalLB (LoadBalancer)                           │   │
│  │  • Traefik (Ingress Controller)                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Applications Kubernetes

| Application | Namespace | Description | Source |
|------------|-----------|-------------|--------|
| GitLab CE | `gitlab` | Forge logicielle + CI/CD | Helm Chart |
| ArgoCD | `argocd` | GitOps & déploiement continu | Helm Chart |
| Harbor | `harbor` | Registry Docker + scan sécurité | Helm Chart |
| Prometheus | `monitoring` | Métriques & alertes | k3s manifest |
| Grafana | `monitoring` | Dashboards | k3s manifest |

### Stack Kubernetes

| Couche | Technologie | Version |
|--------|-------------|---------|
| Distribution | k3s | v1.31.4 |
| Storage | Longhorn | v1.7.x |
| LoadBalancer | MetalLB | v0.14.x |
| Ingress | Traefik (k3s built-in) | v3.x |
| GitOps | ArgoCD | v2.12.x |
| CI/CD | GitLab CI | 17.x |
| Registry | Harbor | v2.15.x |
| Monitoring | Prometheus + Grafana | latest |

### Flux de déploiement GitOps

```
Developer → Git Push → GitLab CI → Build Image → Harbor
                                    │
                                    ▼
                              ArgoCD Sync → k3s → Service
```

1. Développeur push du code sur GitLab
2. GitLab CI build l'image Docker
3. Image pushée sur Harbor
4. ArgoCD détecte le changement
5. ArgoCD sync le déploiement sur k3s

## Architecture logicielle

### Pipeline de déploiement

```
Code source (Git)
    │
    ▼
OpenTofu (création VMs sur Proxmox)
    │
    ▼
Cloud-init (OS + Docker + user)
    │
    ▼
Ansible (configuration système + k3s + services)
    │
    ▼
┌───────────────────────────────────────────┐
│  Docker Compose     │    Kubernetes       │
│  (pve01, apps)      │    (pve02+pve03)    │
│                     │                     │
│  • Traefik          │  • GitLab CE        │
│  • Monitoring       │  • ArgoCD           │
│  • Vaultwarden      │  • Harbor           │
│  • Apps persos      │  • Monitoring       │
└───────────────────────────────────────────┘
```

### Stack technique complète

| Couche | Docker (pve01) | Kubernetes (pve02+pve03) |
|--------|----------------|--------------------------|
| Reverse Proxy | Traefik v3 | Traefik (k3s ingress) |
| Auth | TinyAuth | Authentik (Phase 2) |
| CI/CD | - | GitLab CE + CI |
| GitOps | - | ArgoCD |
| Registry | - | Harbor |
| Sécurité | CrowdSec | Wazuh + Trivy |
| Monitoring | Prometheus + Grafana | Prometheus + Grafana |
| Stockage | Local | Longhorn |
| LoadBalancer | - | MetalLB |

## Diagramme d'architecture global

```
                         INTERNET
                             │
                    Cloudflare Tunnel
                             │
                          Traefik
                             │
                      TinyAuth (auth)
                      CrowdSec (IDS/IPS)
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
    ┌──────┴──────┐   ┌──────┴──────┐   ┌──────┴──────┐
    │   pve01     │   │   pve02     │   │   pve03     │
    │  (16 Go)    │   │  (32 Go)    │   │  (32 Go)    │
    │  Docker     │   │  k3s Node1  │   │  k3s Node2  │
    │             │   │  + Docker   │   │  + Docker   │
    ├─────────────┤   ├─────────────┤   ├─────────────┤
    │ Traefik     │   │ GitLab CE   │   │ Ollama      │
    │ Monitoring  │   │ ArgoCD      │   │ OpenWebUI   │
    │ Vaultwarden │   │ Harbor      │   │ Qdrant      │
    │ Cloudflare  │   │ Paperless   │   │ LangGraph   │
    │             │   │ Immich      │   │             │
    └─────────────┘   └─────────────┘   └─────────────┘
           │                 │                 │
           └─────────────────┴─────────────────┘
                             │
                    Cluster k3s (64 Go)
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

# Déployer uniquement le cluster k3s
ansible-playbook -i inventory.yml playbook.yml --tags k3s

# Déployer uniquement GitLab
ansible-playbook -i inventory.yml playbook.yml --tags gitlab

# Déployer uniquement ArgoCD
ansible-playbook -i inventory.yml playbook.yml --tags argocd
```

## Sauvegarde

### Règle 3-2-1

- **3** copies des données
- **2** supports différents
- **1** copie externe (disque dur physique)

### Flux

```
VM Proxmox → Proxmox Backup Server → Disque dur externe
K8s PVs → Longhorn → Backup S3/external
```

## Maintenance

### Mises à jour

- **Debian** : `unattended-upgrades` (correctifs de sécurité automatiques)
- **Docker** : manuel, via Ansible
- **k3s** : via Ansible (rôle k3s)
- **K8s apps** : via ArgoCD (GitOps)
- **Services Docker** : manuel, via `docker compose pull && docker compose up -d`

### Monitoring

Prometheus collecte les métriques de :
- Proxmox (exporter)
- VMs (node_exporter)
- Containers (cAdvisor)
- k3s (metrics-server)
- GitLab, ArgoCD, Harbor (endpoints custom)

Grafana affiche les dashboards. Alertmanager envoie les alertes sur Discord/Email.
