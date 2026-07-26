# Mounik Personal Cloud Platform

![Status](https://img.shields.io/badge/status-in%20progress-orange)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-red)
![Debian](https://img.shields.io/badge/Debian-13-red)
![Infrastructure](https://img.shields.io/badge/IaC-OpenTofu-blue)
![Automation](https://img.shields.io/badge/Automation-Ansible-black)
![Containers](https://img.shields.io/badge/Containers-Docker-blue)
![Kubernetes](https://img.shields.io/badge/Kubernetes-k3s-blue)
![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-orange)

> Plateforme personnelle auto-hébergée basée sur un cluster Proxmox.
>
> **Double objectif** :
> - **Usage quotidien** — services personnels, cloud privé, assistant IA, automatisation.
> - **Vitrine professionnelle** — démonstration de compétences DevOps/DevSecOps pour les entretiens d'embauche (IaC, Kubernetes, sécurité, IA intégrée).

---

## Sommaire

- [Objectifs](#objectifs)
- [Architecture globale](#architecture-globale)
- [Infrastructure matérielle](#infrastructure-matière)
- [Organisation des nœuds](#organisation-des-nœuds)
- [Stack technique](#stack-technique)
- [Réseau](#réseau)
- [Sécurité](#sécurité)
- [Sauvegarde](#sauvegarde)
- [Intelligence artificielle](#intelligence-artificielle)
- [Observabilité](#observabilité)
- [Services](#services)
- [Organisation Git](#organisation-git)
- [Roadmap](#roadmap)
- [Procédure de reprise après incident](#procédure-de-reprise-après-incident)
- [Documentation associée](#documentation-associée)
- [Licence](#licence)
- [Auteur](#auteur)

---

## Objectifs

### Objectifs personnels

- Centraliser mes données personnelles.
- Remplacer progressivement les services cloud externes.
- Automatiser les tâches répétitives.
- Disposer d'un assistant IA personnel.
- Sécuriser mes données importantes.

### Objectifs professionnels

Ce projet permet de mettre en pratique :

- Administration Linux
- Virtualisation Proxmox
- Infrastructure as Code
- Automatisation Ansible
- Docker & orchestration
- Reverse proxy
- Sécurité
- CI/CD
- Monitoring
- IA appliquée aux opérations

Le homelab doit être utile quotidiennement, documenté, sécurisé, reproductible et automatisé. Chaque modification doit pouvoir être réalisée via code, versionnée avec Git, documentée et restaurée.

---

## Architecture globale

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

---

## Infrastructure matérielle

### Cluster Proxmox

| Nœud  | CPU              | RAM  | Stockage                  |
|-------|------------------|------|---------------------------|
| pve01 | Intel i5-12600H  | 16 Go| NVMe 500 Go + SSD 1 To   |
| pve02 | Intel i5-12600H  | 32 Go| NVMe 500 Go + SSD 1 To   |
| pve03 | Intel i5-12600H  | 32 Go| NVMe 500 Go + SSD 1 To   |

---

## Organisation des nœuds

### pve01 - Infrastructure Core (Docker)

> Services critiques de la plateforme

- Traefik (reverse proxy)
- Cloudflare Tunnel
- TinyAuth (auth centralisée)
- CrowdSec (IDS/IPS)
- Vaultwarden
- Prometheus
- Grafana
- Loki
- Alertmanager

### pve02 - Cloud + k3s Node 01

> Cluster Kubernetes + services personnels

**Kubernetes (24 Go RAM) :**
- GitLab CE (CI/CD)
- ArgoCD (GitOps)
- Harbor (Registry)
- Longhorn (Storage)
- MetalLB (LoadBalancer)

**Docker (8 Go RAM) :**
- Paperless-ngx
- Immich

### pve03 - AI + k3s Node 02

> Cluster Kubernetes + services IA

**Kubernetes (24 Go RAM) :**
- k3s Agent Node
- Monitoring stack

**Docker (8 Go RAM) :**
- Ollama
- OpenWebUI
- Qdrant
- LangGraph
- n8n

---

## Stack technique

### Virtualisation

- Proxmox VE
- VM Debian 13
- LXC lorsque pertinent

### Infrastructure as Code

```
OpenTofu          -> Création VMs sur Proxmox
    │
Ansible           -> Configuration système + k3s
    │
┌───┴───┐
│       │
Docker  Kubernetes
```

### Kubernetes

| Composant | Technologie | Version |
|-----------|-------------|---------|
| Distribution | k3s | v1.31.4 |
| Storage | Longhorn | v1.7.x |
| LoadBalancer | MetalLB | v0.14.x |
| Ingress | Traefik (k3s built-in) | v3.x |
| GitOps | ArgoCD | v2.12.x |
| CI/CD | GitLab CI | 17.x |
| Registry | Harbor | v2.15.x |

### GitOps

```
Developer → Git Push → GitLab CI → Build Image → Harbor
                                    │
                                    ▼
                              ArgoCD Sync → k3s → Service
```

### Système

- Debian 13
- Docker & Docker Compose
- Kubernetes (k3s)
- Bash
- Python

### Réseau

- Freebox Gateway
- Cloudflare DNS & Tunnel
- Traefik v3
- Let's Encrypt

---

## Réseau

### VLAN

| VLAN | ID  | Sous-réseau        | Usage                        |
|------|-----|--------------------|------------------------------|
| Mgmt | 10  | 192.168.10.0/24    | Administration Proxmox/SSH    |
| Infra| 20  | 192.168.20.0/24    | Services critiques (Traefik)  |
| App  | 30  | 192.168.30.0/24    | Services personnels           |
| IA   | 40  | 192.168.40.0/24    | Ollama, LangGraph, n8n        |

### Plan IP

```
Réseau principal : 192.168.1.0/24

192.168.1.254  ->  Freebox (passerelle)
192.168.1.20   ->  pve01
192.168.1.21   ->  pve02
192.168.1.22   ->  pve03
```

---

## Sécurité

### Objectifs

- Aucun service exposé directement sur Internet
- Authentification centralisée
- MFA (authentification multi-facteurs)
- Sauvegardes chiffrées
- Isolation réseau via VLAN
- Firewall nftables sur chaque VM
- Mises à jour de sécurité automatisées
- IDS/IPS collaboratif (CrowdSec)
- WAF applicatif (AppSec)

### Solutions utilisées

| Outil                 | Rôle                                             |
|-----------------------|--------------------------------------------------|
| nftables              | Firewall (par VM)                                |
| VLAN Proxmox          | Isolation réseau                                 |
| TinyAuth              | Auth centralisée (léger, phase 1)                |
| Authentik             | IAM complet (SSO, MFA, SAML — phase 2)          |
| Vaultwarden           | Gestionnaire de secrets                          |
| CrowdSec + Traefik    | IDS/IPS + WAF (protection HTTP)                  |
| CrowdSec Firewall     | Blocage IP au niveau réseau (iptables)           |
| Trivy                 | Scan de sécurité (images Docker)                 |
| Wazuh                 | SIEM & détection d'intrusion                     |
| unattended-upgrades   | Mises à jour auto (Debian)                       |

### Authentification centralisée

**Phase 1 — TinyAuth** (léger) :
- Portail d'auth via ForwardAuth Traefik
- Comptes locaux + OAuth (GitHub)
- ACL basique par application
- 1 conteneur, ~50 Mo RAM

**Phase 2 — Authentik** (migration) :
- IAM complet type entreprise
- SSO, OAuth2/OIDC, SAML, LDAP
- MFA (TOTP, WebAuthn)
- Gestion utilisateurs/groupes avancée
- Compétences IAM pour les entretiens

Architecture TinyAuth (Phase 1) :

```
Utilisateur
    |
    v
Traefik ──> TinyAuth (ForwardAuth)
    |              |
    |              v
    |         Login / OAuth
    |              |
    |              v
    |         Autorisé? ── non ──> 403
    |              |
    |              oui
    v              v
Service cible
```

### CrowdSec + Traefik (IDS/IPS & WAF)

Architecture de protection :

```
Attaquant
    |
    v
Cloudflare Tunnel
    |
    v
Traefik ──> CrowdSec Bouncer (plugin)
    |              |
    |              v
    |         CrowdSec LAPI
    |              |
    |              v
    |         Décision: allow/ban
    |
    v
Service
```

**Fonctionnement :**
1. Traefik génère des logs d'accès (JSON) dans `/opt/traefik/logs/`
2. CrowdSec analyse ces logs en temps réel
3. Le plugin bouncer dans Traefik interroge CrowdSec LAPI
4. Si une IP est bannie → 403 Forbidden
5. Le bouncer firewall bannit aussi l'IP au niveau réseau (iptables)

**Collections CrowdSec actives :**
- `crowdsecurity/traefik` — détection d'attaques spécifiques Traefik
- `crowdsecurity/http-cve` — détection de CVE HTTP
- `crowdsecurity/base-http-scenarios` — scénarios d'attaque HTTP de base
- `crowdsecurity/sshd` — protection brute force SSH
- `crowdsecurity/linux` — protection système Linux
- `crowdsecurity/appsec-generic-rules` — WAF règles génériques
- `crowdsecurity/appsec-virtual-patching` — protection vulnérabilités connues
- `crowdsecurity/appsec-crs` — OWASP Core Rule Set

---

## Sauvegarde

### Règle 3-2-1

- **3** copies des données
- **2** supports différents
- **1** copie externe

### Flux de sauvegarde

```
VM Proxmox
    |
    v
Proxmox Backup Server
    |
    v
Disque dur externe (physique)
```

### Outils

- **Proxmox Backup Server** — sauvegarde des VM/CT
- **restic** — sauvegarde chiffrée des données critiques
- **Chiffrement** — AES-256
- **Fréquence** — quotidienne (VM), hebdomadaire (données)

---

## Intelligence artificielle

### Objectif

Intégrer des modèles d'IA de manière sécurisée dans un environnement d'entreprise. Créer un assistant personnel accessible via Discord / Telegram.

### Choix technique : modèles cloud

Le matériel local (i5-12600H, 32 Go RAM) est trop limité pour faire tourner des modèles performants en local. L'approche consiste à utiliser des **API cloud** (OpenAI, Anthropic, Mistral, etc.) via des proxies sécurisés, ce qui est aussi plus fidèle au contexte professionnel où les modèles cloud sont la norme.

### Architecture

```
Utilisateur
    |
Discord / Telegram
    |
Agent LangGraph
    |
MCP Servers
    |
+--+--+--+
|  |  |  |
API cloud  Services internes
(OpenAI,
Mistral,
Anthropic)
```

### Capacités prévues

#### Assistant documentaire (Second Cerveau)

Obsidian sert de **second cerveau** pour centraliser les notes personnelles, la documentation technique et les connaissances. Le RAG permet de chercher et interroger ce corpus via l'IA.

```
Notes Obsidian (vault)
    |
    v
Indexation Qdrant
    |
    v
Requête via OpenWebUI / Agent LangGraph
    |
    v
Réponse basée sur le corpus local
```

Technologies : `Obsidian + Qdrant + RAG + OpenWebUI + API cloud`

#### Assistant DevOps

- Créer une VM Debian
- Déployer une application
- Analyser un problème
- Créer une documentation

#### Automatisation

`n8n + MCP + LangGraph`

---

## Observabilité

### Stack

```
Prometheus -> Grafana -> Loki -> Alertmanager
```

### Surveillance

- Proxmox
- VM
- Containers
- Services
- Réseau

### Alertes

- Discord
- Email
- Dashboard

---

## Services

### Sous-domaines mounik.ovh

Tous les services sont accessibles via des sous-domaines de `mounik.ovh` :

| Sous-domaine               | Service          | Usage                          |
|----------------------------|------------------|--------------------------------|
| `tinyauth.mounik.ovh`      | TinyAuth         | Authentification centralisée   |
| `vaultwarden.mounik.ovh`   | Vaultwarden      | Gestionnaire de mots de passe  |
| `paperless.mounik.ovh`     | Paperless-ngx    | Documents administratifs       |
| `immich.mounik.ovh`        | Immich           | Photos personnelles            |
| `twenty.mounik.ovh`        | Twenty CRM       | Contacts & candidatures        |
| `actual.mounik.ovh`        | Actual Budget    | Gestion financière             |
| `nextcloud.mounik.ovh`     | Nextcloud        | Cloud personnel                |
| `traefik.mounik.ovh`       | Traefik          | Dashboard reverse proxy        |
| `grafana.mounik.ovh`       | Grafana          | Monitoring                     |
| `gitlab.mounik.ovh`        | GitLab CE        | Forge logicielle + CI/CD       |
| `argocd.mounik.ovh`        | ArgoCD           | GitOps & déploiement continu   |
| `harbor.mounik.ovh`        | Harbor           | Registry Docker + scan sécurité|
| `ollama.mounik.ovh`        | Ollama           | API IA (cloud models)          |
| `openwebui.mounik.ovh`     | OpenWebUI        | Interface IA                   |
| `jobsync.mounik.ovh`       | JobSync          | Tracker candidatures + IA      |
| `n8n.mounik.ovh`           | n8n              | Automatisation                 |
| `wazuh.mounik.ovh`         | Wazuh            | SIEM & sécurité                |

### Services personnels

| Service          | Usage                          | Sous-domaine                  |
|------------------|--------------------------------|-------------------------------|
| TinyAuth         | Authentification centralisée   | `tinyauth.mounik.ovh`         |
| Vaultwarden      | Gestionnaire de mots de passe  | `vaultwarden.mounik.ovh`      |
| Paperless-ngx    | Documents administratifs       | `paperless.mounik.ovh`        |
| Immich           | Photos personnelles            | `immich.mounik.ovh`           |
| Twenty CRM       | Contacts & candidatures        | `twenty.mounik.ovh`           |
| Actual Budget    | Gestion financière             | `actual.mounik.ovh`           |
| Nextcloud        | Cloud personnel                | `nextcloud.mounik.ovh`        |

### Services techniques

| Service         | Usage                      | Sous-domaine                 | Type      |
|-----------------|----------------------------|------------------------------|-----------|
| GitLab CE       | Forge logicielle + CI/CD   | `gitlab.mounik.ovh`          | Kubernetes|
| ArgoCD          | GitOps & déploiement       | `argocd.mounik.ovh`          | Kubernetes|
| Harbor          | Registry Docker + scan     | `harbor.mounik.ovh`          | Kubernetes|
| Trivy           | Scan sécurité images       | — (CLI)                      | CLI       |
| Wazuh           | SIEM & sécurité            | `wazuh.mounik.ovh`           | Kubernetes|
| JobSync         | Tracker candidatures + IA  | `jobsync.mounik.ovh`         | Docker    |

---

## Organisation Git

```
mounik-homelab/
├── README.md
├── .gitignore
├── mkdocs.yml                    # Configuration MkDocs Material
├── requirements-docs.txt         # Dépendances documentation
├── .github/
│   └── workflows/
│       └── docs.yml              # Déploiement GitHub Pages
├── scripts/
│   └── deploy.sh              # Script de déploiement orchestré
├── docs/
│   ├── index.md                # Page d'accueil documentation
│   ├── architecture.md         # Architecture du cluster
│   ├── network.md              # VLANs, sous-domaines
│   ├── security.md             # Sécurité & défense en profondeur
│   └── disaster-recovery.md    # Sauvegardes & restauration
├── terraform/
│   ├── main.tf                 # Point d'entrée
│   ├── providers.tf            # Provider Proxmox
│   ├── variables.tf            # Variables
│   ├── outputs.tf              # Outputs
│   ├── versions.tf             # Versions
│   ├── pve01-infra.tf          # VMs infrastructure (pve01)
│   ├── pve02-cloud.tf          # VMs services personnels (pve02)
│   ├── pve03-ai-devops.tf      # VMs IA & DevOps (pve03)
│   ├── terraform.tfvars.example
│   ├── modules/
│   │   └── vm/main.tf          # Module VM réutilisable
│   └── templates/
│       ├── debian-cloud-init.yaml.tpl
│       └── inventory.yml.tpl
├── ansible/
│   ├── inventory.yml           # Inventaire statique
│   ├── playbook.yml            # Playbook principal
│   └── roles/
│       ├── base/               # Configuration de base
│       ├── docker/             # Installation Docker
│       ├── firewall/           # nftables
│       ├── security-updates/   # unattended-upgrades
│       ├── traefik/            # Traefik v3
│       ├── crowdsec/           # CrowdSec IDS/IPS + WAF
│       ├── tinyauth/           # Auth centralisée (Phase 1)
│       ├── authentik/          # IAM complet (Phase 2)
│       ├── k3s/                # Cluster Kubernetes
│       ├── gitlab-ce/          # GitLab CE (CI/CD)
│       ├── argocd/             # ArgoCD (GitOps)
│       └── harbor/             # Harbor (Registry)
└── diagrams/
```

---

## Déploiement

### Prérequis

```bash
# Installer OpenTofu
curl -fsSL https://get.opentofu.org/install.sh | sh

# Installer Ansible
pip install ansible

# Installer les collections Ansible
ansible-galaxy collection install community.docker community.general kubernetes.core
```

### Déploiement complet

```bash
# 1. Configurer les variables
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Éditer terraform/terraform.tfvars avec tes vraies valeurs

# 2. Lancer le déploiement
./scripts/deploy.sh deploy
```

### Commandes individuelles

```bash
# Initialiser OpenTofu
./scripts/deploy.sh init

# Planifier le déploiement (dry-run)
./scripts/deploy.sh plan

# Appliquer les changements
./scripts/deploy.sh apply

# Configurer les VMs avec Ansible
./scripts/deploy.sh configure

# Voir l'état de l'infrastructure
./scripts/deploy.sh status

# Détruire toutes les VMs
./scripts/deploy.sh destroy

# --- Commandes Kubernetes ---

# Déployer uniquement le cluster k3s
ansible-playbook -i inventory.yml playbook.yml --tags k3s

# Déployer GitLab CE
ansible-playbook -i inventory.yml playbook.yml --tags gitlab

# Déployer ArgoCD
ansible-playbook -i inventory.yml playbook.yml --tags argocd

# Déployer Harbor
ansible-playbook -i inventory.yml playbook.yml --tags harbor

# Voir les pods Kubernetes
kubectl get pods -A

# Voir les services
kubectl get svc -A

# Voir les deployments
kubectl get deployments -A
```

### SSH

```bash
# Générer la clé SSH (fait automatiquement par deploy.sh)
ssh-keygen -t ed25519 -C "mounik-homelab" -f ~/.ssh/mounik-homelab

# Copier la clé sur chaque nœud
ssh-copy-id -i ~/.ssh/mounik-homelab.pub root@192.168.1.20
ssh-copy-id -i ~/.ssh/mounik-homelab.pub root@192.168.1.21
ssh-copy-id -i ~/.ssh/mounik-homelab.pub root@192.168.1.22
```

### Variables requises

| Variable | Description | Exemple |
|----------|-------------|---------|
| `proxmox_endpoint` | URL API Proxmox | `https://192.168.1.20:8006` |
| `proxmox_password` | Mot de passe root | `***` |
| `ssh_public_key` | Clé publique SSH | `ssh-ed25519 AAAA...` |
| `template_name` | Nom du template Debian 13 | `debian-13-template` |

---

## Roadmap

### Phase 1 - Fondation

- [x] Documentation initiale
- [ ] Template Debian 13 (cloner manuellement sur Proxmox)
- [x] OpenTofu Proxmox (terraform/)
- [x] Ansible (ansible/)
- [ ] Sauvegarde (Proxmox Backup Server + disque externe)

### Phase 2 - Infrastructure

- [x] Traefik (role Ansible)
- [ ] Cloudflare Tunnel
- [ ] Authentik
- [ ] Monitoring (Prometheus + Grafana)

### Phase 3 - Services personnels

- [ ] Vaultwarden
- [ ] Paperless-ngx
- [ ] Immich
- [ ] Mealie
- [ ] Actual Budget

### Phase 4 - IA personnelle

- [ ] OpenWebUI
- [ ] Qdrant
- [ ] RAG
- [ ] LangGraph
- [ ] MCP
- [ ] n8n

### Phase 5 - DevSecOps

- [x] GitLab CE (remplace Gitea)
- [x] ArgoCD (GitOps)
- [x] Harbor (Registry)
- [ ] Trivy (scan sécurité)
- [ ] Wazuh (SIEM)

### Phase 6 - Kubernetes

- [x] k3s cluster (2 nœuds)
- [x] Longhorn (storage distribué)
- [x] MetalLB (LoadBalancer)
- [ ] Cert-Manager (TLS automatique)

---

## Procédure de reprise après incident

En cas de perte complète :

1. Réinstaller Proxmox
2. Restaurer le réseau
3. Déployer les VM avec OpenTofu
4. Configurer avec Ansible
5. Restaurer les données
6. Redémarrer les services

**Objectif** : temps de reconstruction < 1 journée.

---

## Documentation associée

- [Architecture](docs/architecture.md) — Vue d'ensemble du cluster et des services
- [Réseau](docs/network.md) — VLANs, plan IP, sous-domaines
- [Sécurité](docs/security.md) — CrowdSec, authentification, firewall
- [Disaster Recovery](docs/disaster-recovery.md) — Sauvegardes et restauration
- Documentation MkDocs : `mkdocs serve` → http://localhost:8000

---

## Licence

Projet personnel. Utilisation libre des concepts et configurations.

---

## Auteur

Laurent — **Mounik Personal Cloud Platform**
