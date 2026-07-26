# Mounik Personal Cloud Platform

![Status](https://img.shields.io/badge/status-in%20progress-orange)
![Proxmox](https://img.shields.io/badge/Proxmox-VE-red)
![Debian](https://img.shields.io/badge/Debian-13-red)
![Infrastructure](https://img.shields.io/badge/IaC-OpenTofu-blue)
![Automation](https://img.shields.io/badge/Automation-Ansible-black)
![Containers](https://img.shields.io/badge/Containers-Docker-blue)
![Kubernetes](https://img.shields.io/badge/Kubernetes-k3s-blue)
![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-orange)

---

## C'est quoi ce projet ?

Imagine que tu puisses **remplacer Google Drive, iCloud, ChatGPT, Google Photos, et toutes tes applications cloud** par quelque chose qui tourne chez toi, dans ton salon, et que tu contrôles à 100%.

C'est exactement ça : un **cloud personnel** — un petit serveur qui vit chez moi et qui me permet de :

- 📁 **Stocker mes fichiers** (comme Google Drive, mais en local)
- 📷 **Sauvegarder mes photos** (comme Google Photos, mais sans Google)
- 🔐 **Gérer mes mots de passe** (comme 1Password, mais en local)
- 🤖 **Discuter avec une IA** (comme ChatGPT, mais en utilisant les API cloud)
- 📋 **Organiser mes documents** (comme un scanner + classeur intelligent)
- 💼 **Suivre mes candidatures** (un tracker d'emploi personnel)
- 🏠 **Piloter ma maison** (domotique, automatisations)

**Double objectif :**

1. **Usage quotidien** — remplacer les services cloud externes par des alternatives auto-hébergées
2. **Vitrine professionnelle** — ce projet reflète les pratiques utilisées en entreprise DevOps/DevSecOps

---

## Pourquoi faire soi-même au lieu de payer un cloud ?

| Problème | Solution |
|----------|----------|
| Google lit tes emails | Tes données restent chez toi |
| 10€/mois par service | Un seul investissement matériel |
| Si le service ferme, tu perds tout | Tu contrôles tout |
| Tu ne sais pas comment ça marche | Tu apprends en le construisant |
| Un employeur veut voir tes skills | Ce projet EST ton CV technique |

---

## L'analogie simple

```
        🏠 CHEZ TOI                    ☁️ INTERNET
   ┌─────────────────┐            ┌─────────────────┐
   │  3 petits PC    │            │  Google / iCloud │
   │  (le serveur)   │            │  (des étrangers) │
   │                 │            │                  │
   │  • Tes photos   │            │  • Tes photos    │
   │  • Tes fichiers │            │  • Tes fichiers  │
   │  • Tes mots de  │            │  • Tes données   │
   │    passe        │            │                  │
   │  • Ton IA       │            │  • ChatGPT       │
   └─────────────────┘            └─────────────────┘
         TU contrôles               EUX contrôlent
```

Les 3 PC (appelés **nœuds**) fonctionnent ensemble comme un seul gros serveur. Si un tombe en panne, les autres prennent le relais.

---

## Comment ça marche ?

### Les 3 serveurs (nœuds)

| Serveur | Rôle | Mémoire | Explication simple |
|---------|------|---------|-------------------|
| **pve01** | Le gardien | 16 Go | Fait tourner les services critiques : sécurité, proxy, monitoring. C'est le "chef" du réseau. |
| **pve02** | Le cloud | 32 Go | Héberge tes données personnelles (photos, documents) + un morceau du cluster Kubernetes. |
| **pve03** | L'IA + DevOps | 32 Go | Fait tourner l'intelligence artificielle (Ollama, LangGraph) + l'autre moitié du cluster. |

### Kubernetes — le cerveau qui coordonne

**C'est quoi Kubernetes ?** C'est un système qui fait tourner tes applications de façon intelligente. Si une application crash, il la redémarre automatiquement. Si tu as besoin de plus de puissance, il distribue le travail entre les serveurs.

**Pourquoi k3s ?** C'est une version allégée de Kubernetes, parfaite pour un homelab. Moins gourmand en ressources, plus simple à maintenir.

**Comment ça marche concrètement :**

```
Tu écris du code → GitLab le compile → Harbor stocke l'image → ArgoCD la déploie
```

C'est comme une chaîne de production automatique :
1. **GitLab** — tu écris le code, il le teste automatiquement
2. **Harbor** — il stocke le "conteneur" (l'application empaquetée)
3. **ArgoCD** — il surveille le code et met à jour l'application en production sans intervention manuelle

---

## La sécurité — comment je protège mes données ?

C'est la partie la plus importante. Voici la stratégie de défense en profondeur :

### Couche par couche

```
Internet
    │
    ▼
┌─────────────────────┐
│  1. Cloudflare      │ ← Bloque les attaques DDoS, cache le contenu
│     Tunnel          │ ← Pas de ports ouverts sur ma box = invisible
├─────────────────────┤
│  2. CrowdSec        │ ← Le "vigile" qui bannit les IPs suspectes
│     + WAF           │ ← Bloque les injections SQL, XSS, etc.
├─────────────────────┤
│  3. TinyAuth        │ ← Tu dois t'identifier avant d'accéder à quoi que ce soit
├─────────────────────┤
│  4. VLAN            │ ← Les services sont isolés en réseau (comme des pièces séparées)
├─────────────────────┤
│  5. nftables        │ ← Firewall local sur chaque VM
├─────────────────────┤
│  6. Chiffrement     │ ← Tes données sont chiffrées (AES-256)
├─────────────────────┤
│  7. Sauvegardes     │ ← Copie quotidienne sur disque externe
└─────────────────────┘
```

### Pourquoi tant de couches ?

Parce que la sécurité, c'est comme un oignon : **plus tu as de couches, plus c'est dur à percer**. Si une couche est compromise, les autres tiennent encore.

---

## Le réseau — comment tout est organisé ?

### Les VLANs (compartiments de sécurité)

Imagine une maison avec des pièces fermées à clé. Chaque pièce a un usage :

| VLAN | Nom | Usage | Analogie |
|------|-----|-------|----------|
| **10** | Management | Accès SSH, administration | Le tableau de bord |
| **20** | Infrastructure | Services critiques (Traefik, monitoring) | Le garage (outils essentiels) |
| **30** | Applications | Services personnels (photos, docs) | Le salon (vie quotidienne) |
| **40** | Intelligence Artificielle | Ollama, LangGraph, n8n | Le bureau (travail) |

### Les sous-domaines

Chaque service a son propre sous-domaine, comme des appartements dans un immeuble :

| Sous-domaine | Service | Usage |
|--------------|---------|-------|
| `vaultwarden.mounik.ovh` | Vaultwarden | Mots de passe |
| `paperless.mounik.ovh` | Paperless-ngx | Documents |
| `immich.mounik.ovh` | Immich | Photos |
| `twenty.mounik.ovh` | Twenty CRM | Contacts |
| `actual.mounik.ovh` | Actual Budget | Finance |
| `nextcloud.mounik.ovh` | Nextcloud | Cloud |
| `gitlab.mounik.ovh` | GitLab CE | Code |
| `argocd.mounik.ovh` | ArgoCD | Déploiement |
| `harbor.mounik.ovh` | Harbor | Registry |
| `openwebui.mounik.ovh` | OpenWebUI | Interface IA |
| `jobsync.mounik.ovh` | JobSync | Candidatures |
| `n8n.mounik.ovh` | n8n | Automatisation |
| `grafana.mounik.ovh` | Grafana | Monitoring |
| `wazuh.mounik.ovh` | Wazuh | Sécurité |

---

## L'intelligence artificielle — pourquoi du cloud ?

### Le problème

Mon serveur est un **Intel i5-12600H avec 32 Go de RAM** — c'est un bon ordinateur portable, pas un serveur d'entreprise. Faire tourner ChatGPT en local sur ce matériel serait comme essayer de faire tourner un jeu AAA sur une calculatrice : techniquement possible, mais les résultats seraient médiocres.

### La solution

Utiliser les **API cloud** (OpenAI, Anthropic, Mistral) via un proxy local. C'est :
- **Plus performant** — les modèles cloud sont 10x plus puissants
- **Plus réaliste** — c'est ce que font les entreprises en vrai
- **Plus économique** — pas besoin de acheter 10 000€ de GPU

### Architecture

```
Toi → Discord/Telegram → LangGraph (l'agent) → API cloud (OpenAI, etc.)
                              │
                              ▼
                         Qdrant (base vectorielle pour le RAG)
```

**Le RAG** (Retrieval-Augmented Generation) permet à l'IA de chercher dans mes notes personnelles pour me répondre. C'est comme avoir un assistant qui a lu tous mes documents et qui peut les citer.

---

## L'infrastructure as code — pourquoi tout est scripté ?

### Le problème

Configurer un serveur à la main, c'est comme cuisiner sans recette : tu peux le faire, mais :
- Tu oublies des étapes
- Tu ne peux pas reproduire le résultat
- Si ça casse, tu ne sais pas comment réparer

### La solution

Tout est écrit en code :

| Outil | Rôle | Analogie |
|-------|------|----------|
| **OpenTofu** | Crée les VMs sur Proxmox | Le architecte qui dessine les plans |
| **Ansible** | Configure les VMs (Docker, sécurité, etc.) | Le maçon qui construit |
| **Docker** | Isole les applications | Les conteneurs d'expédition |
| **Kubernetes** | Orchestre les conteneurs | Le chef d'orchestre |

### Le flux complet

```
OpenTofu crée la VM
       │
       ▼
Ansible installe Docker + configure le firewall
       │
       ▼
Ansible lance le conteneur Docker
       │
       ▼
Le service est prêt !
```

**Tout est versionné avec Git** — si je casse quelque chose, je peux revenir en arrière avec `git revert`.

---

## La sauvegarde — comment je ne perds rien ?

### La règle 3-2-1

C'est la règle d'or des sauvegardes :
- **3** copies des données
- **2** supports différents (NVMe + disque externe)
- **1** copie hors site (disque externe chez moi, pas dans le cloud)

### Le flux

```
Données sur le serveur
       │
       ▼
Proxmox Backup Server (sauvegarde automatique)
       │
       ▼
Disque dur externe (chiffré, à la maison)
```

### Ce qui est sauvegardé

- **Quotidiennement** — VMs complètes
- **Hebdomadairement** — données critiques (Vaultwarden, photos, documents)
- **Chiffrement** — AES-256 (le même standard que les banques)

---

## Les services — à quoi ça sert ?

### Vie quotidienne

| Service | Ce que c'est | Pourquoi |
|---------|-------------|----------|
| **Vaultwarden** | Gestionnaire de mots de passe | Plus besoin de retenir 100 mots de passe |
| **Paperless-ngx** | Scanner et organiser les documents | Adieu les papiers qui s'accumulent |
| **Immich** | Photos personnelles | Google Photos sans Google |
| **Nextcloud** | Cloud personnel | Google Drive sans Google |
| **Twenty CRM** | Contacts et candidatures | Suivre mes contacts et emplois |
| **Actual Budget** | Gestion financière | Savoir où va mon argent |

### Développement

| Service | Ce que c'est | Pourquoi |
|---------|-------------|----------|
| **GitLab CE** | Forge logicielle | Stocker et versionner mon code |
| **ArgoCD** | Déploiement automatique | Mettre à jour les apps sans intervention |
| **Harbor** | Registry Docker | Stocker les images de mes applications |

### Intelligence artificielle

| Service | Ce que c'est | Pourquoi |
|---------|-------------|----------|
| **OpenWebUI** | Interface de chat IA | Discuter avec l'IA facilement |
| **Ollama** | Proxy API IA | Centraliser les appels aux modèles cloud |
| **LangGraph** | Agent IA | Créer des assistants intelligents |
| **n8n** | Automatisation | Connecter les services entre eux |

### Sécurité & Monitoring

| Service | Ce que c'est | Pourquoi |
|---------|-------------|----------|
| **Traefik** | Reverse proxy | Diriger le trafic vers les bonnes apps |
| **TinyAuth** | Authentification | Un seul mot de passe pour tout |
| **CrowdSec** | IDS/IPS | Détecter et bloquer les intrusions |
| **Prometheus** | Collecte de métriques | Surveiller CPU, RAM, disque, containers |
| **Grafana** | Tableaux de bord | Visualiser les métriques en temps réel |
| **Loki** | Agrégation de logs | Centraliser et chercher dans les logs |
| **Alertmanager** | Alertes | Recevoir des notifications en cas de problème |
| **Wazuh** | SIEM | Détecter les menaces avancées |

---

## Stack technique — pourquoi ces choix ?

En milieu professionnel, on choisit les outils selon leur fiabilité, leur communauté, et leur écosystème. Voici la logique derrière chaque choix :

### Infrastructure

| Composant | Technologie | Version | Pourquoi ce choix ? |
|-----------|-------------|---------|---------------------|
| Hyperviseur | Proxmox VE | 8.x | Open source, léger, bien documenté, gratuit |
| OS VMs | Debian 13 | — | Stabilité, support à long terme, pas de surprises |
| IaC | OpenTofu | 1.8+ | Fork open source de Terraform, pas de license fees |
| Config Management | Ansible | 2.17+ | Agentless (pas d'agent à installer), simple, puissant |

### Kubernetes

| Composant | Technologie | Version | Pourquoi ce choix ? |
|-----------|-------------|---------|---------------------|
| Distribution | k3s | v1.31.4 | Léger, parfait pour 2-3 nœuds, pas 100 |
| Storage | Longhorn | v1.7.x | Stockage distribué, snapshots automatiques |
| LoadBalancer | MetalLB | v0.14.x | Donne des IPs aux services K8s (sinon inaccessibles) |
| GitOps | ArgoCD | v2.12.x | Déploiement continu, rollback en 1 clic |
| CI/CD | GitLab CI | 17.x | Intégration native avec GitLab CE, pas de configexterne |
| Registry | Harbor | v2.15.x | Scan de sécurité intégré (Trivy), registry privé |

### Sécurité

| Composant | Technologie | Usage |
|-----------|-------------|-------|
| Firewall | nftables | Par VM |
| IDS/IPS | CrowdSec | Logs + blocage automatique |
| WAF | CrowdSec AppSec | Protection applicative |
| Auth | TinyAuth → Authentik | SSO + MFA |
| SIEM | Wazuh | Détection d'intrusion |

---

## Déploiement

### Prérequis

```bash
# Installer OpenTofu (le "dessinateur de plans")
curl -fsSL https://get.opentofu.org/install.sh | sh

# Installer Ansible (le "maçon")
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

# Planifier le déploiement (dry-run — rien n'est changé)
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
```

### SSH

```bash
# Générer la clé SSH
ssh-keygen -t ed25519 -C "mounik-homelab" -f ~/.ssh/mounik-homelab

# Copier la clé sur chaque nœud
ssh-copy-id -i ~/.ssh/mounik-homelab.pub root@192.168.1.20
ssh-copy-id -i ~/.ssh/mounik-homelab.pub root@192.168.1.21
ssh-copy-id -i ~/.ssh/mounik-homelab.pub root@192.168.1.22
```

---

## Organisation du projet

```
mounik-homelab/
├── README.md                    # Ce fichier
├── mkdocs.yml                   # Configuration documentation
├── .github/workflows/docs.yml   # Déploiement GitHub Pages
├── scripts/deploy.sh            # Script de déploiement
├── docs/                        # Documentation détaillée
│   ├── architecture.md          # Architecture technique
│   ├── network.md               # Réseau, VLANs, sous-domaines
│   ├── security.md              # Sécurité détaillée
│   └── disaster-recovery.md     # Sauvegardes et restauration
├── terraform/                   # Infrastructure as Code (OpenTofu)
│   ├── pve01-infra.tf           # VMs infrastructure
│   ├── pve02-cloud.tf           # VMs services personnels
│   ├── pve03-ai-devops.tf       # VMs IA & DevOps
│   └── modules/vm/              # Module VM réutilisable
├── ansible/                     # Configuration automatisée
│   ├── inventory.yml            # Liste des serveurs
│   ├── playbook.yml             # Instructions de configuration
│   └── roles/                   # Rôles (base, docker, k3s, etc.)
└── diagrams/                    # Schémas d'architecture
```

---

## Roadmap

### Phase 1 — Fondation ✅

- [x] Documentation initiale
- [ ] Template Debian 13
- [x] OpenTofu (création VMs)
- [x] Ansible (configuration)
- [ ] Sauvegarde (PBS + disque externe)

### Phase 2 — Infrastructure

- [x] Traefik (reverse proxy)
- [ ] Cloudflare Tunnel
- [ ] Authentik (IAM complet)
- [x] Monitoring (Prometheus + Grafana + Loki + Alertmanager)

### Phase 3 — Services personnels

- [ ] Vaultwarden
- [ ] Paperless-ngx
- [ ] Immich
- [ ] Twenty CRM
- [ ] Actual Budget

### Phase 4 — IA personnelle

- [ ] OpenWebUI
- [ ] Qdrant (base vectorielle)
- [ ] RAG (recherche dans les notes)
- [ ] LangGraph (agent IA)
- [ ] n8n (automatisation)

### Phase 5 — DevSecOps

- [x] GitLab CE
- [x] ArgoCD
- [x] Harbor
- [ ] Trivy (scan sécurité)
- [ ] Wazuh (SIEM)

### Phase 6 — Kubernetes

- [x] k3s cluster (2 nœuds)
- [x] Longhorn (storage distribué)
- [x] MetalLB (LoadBalancer)
- [ ] Cert-Manager (TLS automatique)

---

## Procédure de reprise après incident

En cas de perte complète (incendie, vol, panne totale) :

1. Réinstaller Proxmox sur les 3 serveurs
2. Restaurer le réseau (VLANs, firewall)
3. Déployer les VM avec OpenTofu (`./scripts/deploy.sh apply`)
4. Configurer avec Ansible (`./scripts/deploy.sh configure`)
5. Restaurer les données depuis le disque externe
6. Redémarrer les services

**Objectif** : temps de reconstruction < 1 journée.

---

## Documentation associée

- [Architecture](docs/architecture.md) — Vue d'ensemble du cluster et des choix techniques
- [Réseau](docs/network.md) — VLANs, plan IP, sous-domaines, firewall
- [Services](docs/services.md) — Guide complet de chaque service
- [Sécurité](docs/security.md) — Les 7 couches de protection
- [Disaster Recovery](docs/disaster-recovery.md) — Sauvegardes et restauration
- [Glossaire](docs/glossary.md) — Termes techniques expliqués pour les non-initiés
- Documentation MkDocs : `mkdocs serve` → http://localhost:8000

---

## Licence

Projet personnel. Utilisation libre des concepts et configurations.

---

## Auteur

Laurent — **Mounik Personal Cloud Platform**
