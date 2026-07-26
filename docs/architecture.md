# Architecture du Cluster

## Vue d'ensemble

Le Mounik Personal Cloud Platform est un **cluster de 3 ordinateurs** (appelés "nœuds") qui fonctionnent ensemble comme un seul gros serveur. L'objectif est de remplacer les services cloud (Google, iCloud, etc.) par des alternatives auto-hébergées, tout en démontrant des compétences DevOps pour les entretiens.

### L'analogie

Imagine un restaurant avec 3 cuisiniers :  
- **pve01** — Le chef qui gère la sécurité et les commandes (Traefik, CrowdSec, monitoring)  
- **pve02** — Le cuisinier principal qui prépare les plats quotidiens (photos, documents, cloud)  
- **pve03** — Le chef pâtissier spécialisé en desserts complexes (IA, automatisation)

Chaque cuisinier a son rôle, mais ils collaborent pour servir les clients (toi).

---

## Architecture physique

### Cluster Proxmox

| Nœud  | CPU              | RAM  | Stockage                  | Rôle |
|-------|------------------|------|---------------------------|------|
| pve01 | Intel i5-12600H  | 16 Go| NVMe 500 Go + SSD 1 To   | Le gardien — services critiques |
| pve02 | Intel i5-12600H  | 32 Go| NVMe 500 Go + SSD 1 To   | Le cloud — données personnelles |
| pve03 | Intel i5-12600H  | 32 Go| NVMe 500 Go + SSD 1 To   | L'IA + DevOps — intelligence artificielle |

### Pourquoi 3 serveurs ?

1. **Redondance** — si un tombe en panne, les autres continuent de fonctionner
2. **Isolation** — chaque type de service a son propre espace (sécurité, données, IA)
3. **Performance** — on répartit la charge pour que rien ne ralentisse
4. **Apprentissage** — c'est comme ça qu'on fait en entreprise (cluster, distribution de charge)

### Pourquoi Proxmox ?

**Proxmox VE** est un hyperviseur open source (gratuit) qui permet de créer des machines virtuelles (VMs) sur du matériel physique. C'est l'équivalent de VMware ESXi mais gratuit et mieux adapté à un homelab.

**Choix technique :** Proxmox est choisi pour :  
- Son interface web intuitive  
- Son support de clustering (plusieurs serveurs qui collaborent)  
- Sa communauté active et sa documentation  
- Son coût (gratuit vs VMware qui coûte cher)

---

## Répartition des services

### pve01 — Infrastructure Core (16 Go RAM)

C'est le **serveur de sécurité et d'infrastructure**. Il fait tourner les services critiques qui doivent toujours être disponibles.

| Service          | VM ID | IP               | RAM   | Description |
|------------------|-------|------------------|-------|-------------|
| traefik          | 100   | 192.168.20.100   | 2 Go  | Reverse proxy — le "guichet d'accueil" qui redirige le trafic |
| monitoring       | 101   | 192.168.20.101   | 4 Go  | Prometheus + Grafana — les "caméras de surveillance" |
| vaultwarden      | 103   | 192.168.20.103   | 1 Go  | Gestionnaire de mots de passe |
| cloudflare-tunnel| 104   | 192.168.20.104   | 512 Mo| Tunnel sécurisé vers Internet |

**Pourquoi pve01 est plus petit (16 Go) ?**
Parce que les services d'infrastructure sont légers. Traefik consomme ~200 Mo, Vaultwarden ~100 Mo. On n'a pas besoin de 32 Go pour ça.

### pve02 — Cloud + k3s Node 01 (32 Go RAM)

C'est le **serveur de données personnelles**. Il héberge tes photos, documents, et un morceau du cluster Kubernetes.

| Service          | VM ID | IP               | RAM   | Description |
|------------------|-------|------------------|-------|-------------|
| **k3s-node01**   | 200   | 192.168.20.200   | 24 Go | Nœud principal du cluster Kubernetes |
| paperless        | 210   | 192.168.30.100   | 4 Go  | Scanner et organiser les documents |
| immich           | 211   | 192.168.30.101   | 4 Go  | Photos personnelles (comme Google Photos) |
| twenty-crm       | 213   | 192.168.30.103   | 4 Go  | Contacts et candidatures d'emploi |

**Pourquoi pve02 a plus de RAM (32 Go) ?**
Parce qu'il fait tourner Kubernetes (24 Go) + les applications personnelles (8 Go). Kubernetes est gourmand en mémoire.

### pve03 — AI + k3s Node 02 (32 Go RAM)

C'est le **serveur d'intelligence artificielle**. Il héberge les modèles d'IA et l'autre moitié du cluster Kubernetes.

| Service          | VM ID | IP               | RAM   | Description |
|------------------|-------|------------------|-------|-------------|
| **k3s-node02**   | 300   | 192.168.20.210   | 24 Go | Nœud secondaire du cluster Kubernetes |
| ollama           | 310   | 192.168.40.100   | 8 Go  | Proxy API IA (OpenAI, Anthropic, Mistral) |
| open-webui       | 311   | 192.168.40.101   | 4 Go  | Interface de chat IA (comme ChatGPT) |
| jobsync          | 315   | 192.168.40.105   | 2 Go  | Tracker de candidatures d'emploi |

---

## Architecture Kubernetes (k3s)

### C'est quoi Kubernetes ?

**Kubernetes** (ou K8s) est un système qui fait tourner des applications de façon intelligente. C'est comme un **chef d'orchestre** qui distribue le travail entre les serveurs.

**Analogie :** Imagine un restaurant avec plusieurs cuisiniers. Kubernetes décide quel cuisinier prépare quel plat, vérifie que tout va bien, et remplace un cuisinier s'il tombe malade.

### Pourquoi k3s ?

k3s est une version **allégée** de Kubernetes, parfaite pour un homelab :  
- Moins gourmand en ressources (500 Mo de RAM vs 2 Go pour K8s classique)  
- Plus simple à installer et à maintenir  
- Parfait pour 2-3 nœuds (pas besoin de 100 nœuds comme Google)

### Le cluster

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
│  │  • Longhorn (stockage distribué)                    │   │
│  │  • MetalLB (équilibreur de charge)                  │   │
│  │  • Traefik (contrôleur d'entrée)                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Server vs Agent :**  
- **Server** (k3s-node01) : le "cerveau" qui gère le cluster  
- **Agent** (k3s-node02) : le "travailleur" qui exécute les tâches

### Applications Kubernetes

| Application | Namespace | Description | Source |
|------------|-----------|-------------|--------|
| GitLab CE | `gitlab` | Forge logicielle + CI/CD | Helm Chart |
| ArgoCD | `argocd` | GitOps & déploiement continu | Helm Chart |
| Harbor | `harbor` | Registry Docker + scan sécurité | Helm Chart |
| Prometheus | `monitoring` | Métriques & alertes | k3s manifest |
| Grafana | `monitoring` | Dashboards | k3s manifest |

### Stack Kubernetes

| Couche | Technologie | Version | Pourquoi ? |
|--------|-------------|---------|------------|
| Distribution | k3s | v1.31.4 | Léger, parfait pour homelab |
| Stockage | Longhorn | v1.7.x | Stockage distribué entre les nœuds |
| Équilibreur | MetalLB | v0.14.x | Expose les services avec des IPs |
| Entrée | Traefik (k3s built-in) | v3.x | Gère le trafic HTTP/HTTPS |
| GitOps | ArgoCD | v2.12.x | Déploiement continu basé sur Git |
| CI/CD | GitLab CI | 17.x | Teste et build le code automatiquement |
| Registry | Harbor | v2.15.x | Stocke les images Docker en local |

### Flux de déploiement GitOps

```
Developer → Git Push → GitLab CI → Build Image → Harbor
                                    │
                                    ▼
                              ArgoCD Sync → k3s → Service
```

1. **Tu écris du code** → tu le pousses sur GitLab
2. **GitLab CI** compile et teste ton code automatiquement
3. **Harbor** stocke l'image Docker
4. **ArgoCD** détecte le changement et déploie sur Kubernetes
5. **Le service est mis à jour** sans intervention manuelle

---

## Architecture logicielle

### Le pipeline complet

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

### Docker vs Kubernetes — quand utiliser quoi ?

| Critère | Docker Compose | Kubernetes |
|---------|---------------|------------|
| Complexité | Simple (1 fichier YAML) | Complexe (manifests multiples) |
| Scalabilité | Manuelle | Automatique |
| Haute disponibilité | Non | Oui |
| Cas d'usage | Apps simples, pve01 | Apps critiques, cluster |
| Maintenance | Facile | Plus complexe |

**Pourquoi les deux ?**  
- **Docker Compose** pour les services simples sur pve01 (Traefik, Vaultwarden)  
- **Kubernetes** pour les services critiques sur pve02+pve03 (GitLab, ArgoCD, Harbor)

### Stack technique complète

| Couche | Docker (pve01) | Kubernetes (pve02+pve03) |
|--------|----------------|--------------------------|
| Reverse Proxy | Traefik v3 | Traefik (k3s ingress) |
| Auth | TinyAuth | Authentik (Phase 2) |
| CI/CD | — | GitLab CE + CI |
| GitOps | — | ArgoCD |
| Registry | — | Harbor |
| Sécurité | CrowdSec | Wazuh + Trivy |
| Monitoring | Prometheus + Grafana | Prometheus + Grafana |
| Stockage | Local | Longhorn |
| LoadBalancer | — | MetalLB |

---

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

---

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

---

## Maintenance

### Mises à jour

| Composant | Méthode | Fréquence |
|-----------|---------|-----------|
| Debian | `unattended-upgrades` (automatique) | Quotidienne |
| Docker | via Ansible | Mensuelle |
| k3s | via Ansible | Mensuelle |
| K8s apps | via ArgoCD (GitOps) | Continue |
| Services Docker | `docker compose pull && up -d` | Manuelle |

### Monitoring

Prometheus collecte les métriques de :  
- **Proxmox** — état des VMs, CPU, RAM, disque  
- **VMs** — node_exporter (métriques système)  
- **Containers** — cAdvisor (métriques Docker)  
- **k3s** — metrics-server (métriques Kubernetes)  
- **Applications** — GitLab, ArgoCD, Harbor (endpoints custom)

Grafana affiche les dashboards. Alertmanager envoie les alertes sur Discord/Email.
