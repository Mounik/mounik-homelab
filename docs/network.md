# Documentation Réseau

## Vue d'ensemble

Le réseau du homelab est organisé en **VLANs** (Virtual Local Area Networks) — des réseaux virtuels qui séparent physiquement les différents types de trafic. C'est la même technique utilisée dans les grandes entreprises pour sécuriser leur infrastructure.

### L'analogie

Imagine un immeuble de bureaux :  
- **Étage 1 (VLAN 10)** — La salle serveur (management)  
- **Étage 2 (VLAN 20)** — Le local technique   (infrastructure critique)  
- **Étage 3 (VLAN 30)** — Les bureaux (services personnels)  
- **Étage 4 (VLAN 40)** — Le laboratoire R&D (intelligence artificielle)

Chaque étage a sa propre serrure. Pour passer d'un étage à l'autre, il faut une autorisation explicite.

---

## Topologie réseau

```
Internet
    │
    ▼
Freebox (192.168.1.254)  ← La box Internet
    │  VLAN trunk
    ▼
Switch (管理 VLANs)
    ├── pve01 (192.168.1.20)
    ├── pve02 (192.168.1.21)
    └── pve03 (192.168.1.22)
```

### Pourquoi une Freebox ?

C'est ma box Internet. Elle fait le pont entre Internet et mon réseau local. Le switch derrière distribue le trafic vers les 3 serveurs.

---

## Les VLANs — pourquoi les séparer ?

### Le problème

Si tous les services sont sur le même réseau, une attaque sur un service peut se propager à tous les autres. C'est comme une maison sans portes intérieures : si un voleur entre, il a accès à tout.

### La solution

Les VLANs créent des **réseaux virtuels séparés**. Chaque VLAN a son propre sous-réseau IP et ses propres règles de firewall.

| VLAN | ID  | Sous-réseau        | Usage | Analogie |
|------|-----|--------------------|-------|----------|
| Mgmt | 10  | 192.168.10.0/24   | SSH, API Proxmox | La clé du serveur |
| Infra| 20  | 192.168.20.0/24   | Traefik, monitoring | Le local technique |
| App  | 30  | 192.168.30.0/24   | Services personnels | Les bureaux |
| IA   | 40  | 192.168.40.0/24   | Ollama, LangGraph, n8n | Le labo R&D |

### Règles d'or

- **Pas de communication inter-VLAN par défaut** — chaque VLAN est isolé
- **Seul le VLAN Management (10) peut accéder aux autres VLANs** — c'est le "super admin"
- **Le trafic HTTP/HTTPS traverse les VLANs** via Traefik (le reverse proxy)

---

## Plan IP complet

### Passerelle
- Freebox : `192.168.1.254`

### Nœuds Proxmox

| Nœud  | IP principale     | VLAN Mgmt        | VLAN Infra       |
|-------|-------------------|------------------|------------------|
| pve01 | 192.168.1.20     | 192.168.10.20   | 192.168.20.20   |
| pve02 | 192.168.1.21     | 192.168.10.21   | 192.168.20.21   |
| pve03 | 192.168.1.22     | 192.168.10.22   | 192.168.20.22   |

### VMs — Plan IP détaillé

| VM            | IP               | VLAN | Nœud  | Description |
|---------------|------------------|------|-------|-------------|
| traefik       | 192.168.20.100   | 20   | pve01 | Reverse proxy |
| monitoring    | 192.168.20.101   | 20   | pve01 | Prometheus + Grafana |
| vaultwarden   | 192.168.20.103   | 20   | pve01 | Mots de passe |
| k3s-node01    | 192.168.20.200   | 20   | pve02 | Cluster Kubernetes |
| k3s-node02    | 192.168.20.210   | 20   | pve03 | Cluster Kubernetes |
| paperless     | 192.168.30.100   | 30   | pve02 | Documents |
| immich        | 192.168.30.101   | 30   | pve02 | Photos |
| nextcloud     | 192.168.30.102   | 30   | pve02 | Cloud |
| twenty-crm    | 192.168.30.103   | 30   | pve02 | Contacts |
| actual-budget | 192.168.30.104   | 30   | pve02 | Finance |
| home-assistant| 192.168.30.105   | 30   | pve02 | Domotique |
| plex          | 192.168.30.106   | 30   | pve02 | Médias |
| ollama        | 192.168.40.100   | 40   | pve03 | API IA |
| open-webui    | 192.168.40.101   | 40   | pve03 | Interface IA |
| qdrant        | 192.168.40.102   | 40   | pve03 | Base vectorielle |
| langgraph     | 192.168.40.103   | 40   | pve03 | Agent IA |
| n8n           | 192.168.40.104   | 40   | pve03 | Automatisation |
| jobsync       | 192.168.40.105   | 40   | pve03 | Candidatures |

---

## Firewall (nftables)

### C'est quoi un firewall ?

Un firewall est comme un **gardien de porte** qui décide quel trafic est autorisé ou non. Sur chaque VM, nftables (le firewall Linux) applique les règles suivantes :

| Règle | Explication |
|-------|-------------|
| **Policy DROP** | Par défaut, tout est bloqué. Seul le trafic explicitement autorisé passe. |
| **Loopback autorisé** | Les VMs peuvent communiquer avec elles-mêmes (nécessaire pour les apps) |
| **Connexions établies** | Si tu as initié une connexion, la réponse est autorisée |
| **SSH admin uniquement** | Seuls les réseaux admin (192.168.1.0/24, 192.168.10.0/24) peuvent se connecter en SSH |
| **HTTP/HTTPS ouvert** | Traefik accepte les connexions web de l'extérieur |
| **Services admin restreints** | Grafana, Prometheus, Traefik dashboard : admin uniquement |
| **Tout le reste DROP** | Le reste est bloqué avec logging (pour les logs de sécurité) |

---

## DNS et sous-domaines

### Comment ça marche ?

Quand tu tapes `gitlab.mounik.ovh` dans ton navigateur :

```
1. Ton navigateur interroge Cloudflare (le DNS)
2. Cloudflare redirige vers le Cloudflare Tunnel
3. Le tunnel envoie le trafic vers Traefik
4. Traefik identifie le sous-domaine et redirige vers le bon service
```

### Pourquoi Cloudflare ?

- **Protection DDoS** — Cloudflare absorbe les attaques massives
- **Cache** — les pages statiques sont servies plus rapidement
- **SSL/TLS** — le chiffrement est géré par Cloudflare
- **Aucun port ouvert** — le tunnel sortant évite d'ouvrir des ports sur ma box

### Sous-domaines

```
*.mounik.ovh  →  Cloudflare Tunnel  →  Traefik  →  Service
```

| Sous-domaine               | IP destination      | VLAN | Port | Service |
|----------------------------|---------------------|------|------|---------|
| `tinyauth.mounik.ovh`      | 192.168.20.100      | 20   | 443  | Authentification |
| `vaultwarden.mounik.ovh`   | 192.168.20.103      | 20   | 443  | Mots de passe |
| `paperless.mounik.ovh`     | 192.168.30.100      | 30   | 443  | Documents |
| `immich.mounik.ovh`        | 192.168.30.101      | 30   | 443  | Photos |
| `nextcloud.mounik.ovh`     | 192.168.30.102      | 30   | 443  | Cloud |
| `twenty.mounik.ovh`        | 192.168.30.103      | 30   | 443  | Contacts |
| `actual.mounik.ovh`        | 192.168.30.104      | 30   | 443  | Finance |
| `grafana.mounik.ovh`       | 192.168.20.101      | 20   | 443  | Monitoring |
| `traefik.mounik.ovh`       | 192.168.20.100      | 20   | 443  | Dashboard proxy |
| `gitlab.mounik.ovh`        | 192.168.20.200      | 20   | 443  | Code |
| `argocd.mounik.ovh`        | 192.168.20.200      | 20   | 443  | Déploiement |
| `harbor.mounik.ovh`        | 192.168.20.200      | 20   | 443  | Registry |
| `jobsync.mounik.ovh`       | 192.168.40.105      | 40   | 443  | Candidatures |
| `wazuh.mounik.ovh`         | 192.168.20.210      | 20   | 443  | Sécurité |
| `ollama.mounik.ovh`        | 192.168.40.100      | 40   | 443  | API IA |
| `openwebui.mounik.ovh`     | 192.168.40.101      | 40   | 443  | Interface IA |
| `n8n.mounik.ovh`           | 192.168.40.104      | 40   | 443  | Automatisation |

---

## Flux réseau complet

```
Utilisateur (toi)
    │
    ▼
Internet
    │
    ▼
Freebox (NAT) ← Pas de ports ouverts
    │
    ▼
Cloudflare Tunnel (sortant) ← Sécurisé, chiffré
    │
    ▼
Traefik (VLAN 20) ← Le guichet d'accueil
    │
    ▼
TinyAuth (auth) ← Tu dois t'identifier
    │
    ▼
CrowdSec (IDS/IPS) ← Le vigile vérifie
    │
    ▼
Services (VLAN 30/40) ← Le bon service est appelé
```

### Pourquoi pas de ports ouverts sur la box ?

C'est la **règle d'or de la sécurité réseau**. Si tu ouvres un port sur ta box, n'importe qui sur Internet peut essayer de se connecter. En utilisant un tunnel sortant (Cloudflare Tunnel), c'est **toi** qui établis la connexion, pas l'extérieur.

---

## Pourquoi ce choix réseau ?

En milieu professionnel, les entreprises utilisent des VLANs pour isoler les réseaux. C'est la norme dans les datacenters et les grandes entreprises. J'applique la même logique ici :

| Choix | Raison professionnelle |
|-------|----------------------|
| VLANs | En entreprise, on sépare le réseau admin, production, et development |
| nftables | C'est le firewall standard de Linux, utilisé partout en production |
| DNS Cloudflare | Les entreprises utilisent des reverse DNS pour la sécurité et le cache |
| Reverse proxy | Traefik est utilisé dans les environnements Docker/Kubernetes en entreprise |
| Zero-trust | Le modèle zero-trust (aucun port ouvert) est la tendance actuelle en sécurité |
| Logs | En entreprise, on log tout pour pouvoir investiguer en cas d'incident |
