# Mounik Personal Cloud Platform

![Status](https://img.shields.io/badge/status-in%20progress-orange)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-red)
![Debian](https://img.shields.io/badge/Debian-13-red)
![Infrastructure](https://img.shields.io/badge/IaC-OpenTofu-blue)
![Automation](https://img.shields.io/badge/Automation-Ansible-black)
![Containers](https://img.shields.io/badge/Containers-Docker-blue)

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

### pve01 - Infrastructure Core

> Services critiques de la plateforme

- Traefik
- Cloudflare Tunnel
- TinyAuth (auth centralisée)
- CrowdSec (IDS/IPS)
- Vaultwarden
- Prometheus
- Grafana
- Loki
- Alertmanager
- Uptime Kuma

### pve02 - Personal Cloud

> Services utilisés au quotidien

- Paperless-ngx
- Immich
- Nextcloud
- Mealie
- Actual Budget
- Home Assistant
- Plex

### pve03 - AI & DevOps Lab

> Expérimentation, développement et automatisation

- OpenWebUI
- Ollama
- Qdrant
- LangGraph
- n8n
- Git
- CI/CD
- Security Tools

---

## Stack technique

### Virtualisation

- Proxmox VE
- VM Debian 13
- LXC lorsque pertinent

### Infrastructure as Code

```
OpenTofu          -> Création VM/LXC
    |
Ansible           -> Configuration système
    |
Docker Compose    -> Applications
```

### Système

- Debian 13
- Docker & Docker Compose
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
| `mealie.mounik.ovh`        | Mealie           | Recettes                       |
| `actual.mounik.ovh`        | Actual Budget    | Gestion financière             |
| `nextcloud.mounik.ovh`     | Nextcloud        | Cloud personnel                |
| `obsidian.mounik.ovh`      | Obsidian (web)   | Second cerveau / notes         |
| `traefik.mounik.ovh`       | Traefik          | Dashboard reverse proxy        |
| `grafana.mounik.ovh`       | Grafana          | Monitoring                     |
| `gitea.mounik.ovh`         | Gitea            | Forge logicielle               |
| `harbor.mounik.ovh`        | Harbor           | Registry Docker                |
| `ollama.mounik.ovh`        | Ollama           | API IA (cloud models)          |
| `openwebui.mounik.ovh`     | OpenWebUI        | Interface IA                   |
| `n8n.mounik.ovh`           | n8n              | Automatisation                 |
| `wazuh.mounik.ovh`         | Wazuh            | SIEM & sécurité                |

### Services personnels

| Service          | Usage                          | Sous-domaine                  |
|------------------|--------------------------------|-------------------------------|
| TinyAuth         | Authentification centralisée   | `tinyauth.mounik.ovh`         |
| Vaultwarden      | Gestionnaire de mots de passe  | `vaultwarden.mounik.ovh`      |
| Paperless-ngx    | Documents administratifs       | `paperless.mounik.ovh`        |
| Immich           | Photos personnelles            | `immich.mounik.ovh`           |
| Mealie           | Recettes                       | `mealie.mounik.ovh`           |
| Actual Budget    | Gestion financière             | `actual.mounik.ovh`           |
| Nextcloud        | Cloud personnel                | `nextcloud.mounik.ovh`        |
| Obsidian         | Second cerveau / notes         | `obsidian.mounik.ovh`         |

### Services techniques

| Service         | Usage                      | Sous-domaine                 |
|-----------------|----------------------------|------------------------------|
| Gitea           | Forge logicielle           | `gitea.mounik.ovh`           |
| Harbor          | Registry Docker            | `harbor.mounik.ovh`          |
| DefectDojo      | Gestion vulnérabilités     | —                            |
| Trivy           | Scan sécurité              | — (CLI)                      |
| Wazuh           | SIEM & sécurité            | `wazuh.mounik.ovh`           |

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
│       └── authentik/          # IAM complet (Phase 2)
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
ansible-galaxy collection install community.docker community.general
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

- [ ] GitLab/Gitea
- [ ] CI/CD
- [ ] Trivy
- [ ] DefectDojo
- [ ] Wazuh
- [ ] Security Dashboard

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

- Documentation utilisateur : [https://mounik.ovh](https://mounik.ovh)
- Documentation technique : `/docs`

---

## Licence

Projet personnel. Utilisation libre des concepts et configurations.

---

## Auteur

Laurent — **Mounik Personal Cloud Platform**
