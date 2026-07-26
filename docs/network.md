# Documentation Réseau - mounik-homelab

## Vue d'ensemble

Le réseau du homelab utilise des **VLANs** pour isoler les différents types de traffic. Cette approche est celle utilisée en entreprise et démontre les compétences réseau pour les entretiens.

## Topologie

```
Internet
    |
Freebox (192.168.1.254)
    |  VLAN trunk
    |
Switch
    |--- pve01 (192.168.1.20)
    |--- pve02 (192.168.1.21)
    |--- pve03 (192.168.1.22)
```

## VLANs

| VLAN | ID  | Sous-réseau        | Usage                              | Ports ouverts              |
|------|-----|--------------------|------------------------------------|----------------------------|
| Mgmt | 10  | 192.168.10.0/24   | SSH, API Proxmox                   | 22 (SSH), 8006 (PVE API)  |
| Infra| 20  | 192.168.20.0/24   | Traefik, TinyAuth, monitoring      | 80, 443, 8080, 9090, 3000 |
| App  | 30  | 192.168.30.0/24   | Services personnels                | 80, 443                   |
| IA   | 40  | 192.168.40.0/24   | Ollama, LangGraph, n8n             | 80, 443, 11434           |

## Plan IP

### Passerelle
- Freebox : `192.168.1.254`

### Nœuds Proxmox
| Nœud  | IP principale     | VLAN Mgmt        | VLAN Infra       |
|-------|-------------------|------------------|------------------|
| pve01 | 192.168.1.20     | 192.168.10.20   | 192.168.20.20   |
| pve02 | 192.168.1.21     | 192.168.10.21   | 192.168.20.21   |
| pve03 | 192.168.1.22     | 192.168.10.22   | 192.168.20.22   |

### VMs (exemple)
| VM       | IP               | VLAN   | Nœud  |
|----------|------------------|--------|-------|
| traefik  | 192.168.20.100   | 20     | pve01 |
| grafana  | 192.168.20.101   | 20     | pve01 |
| nextcloud| 192.168.30.100   | 30     | pve02 |
| ollama   | 192.168.40.100   | 40     | pve03 |

## Firewall (nftables)

Chaque VM utilise nftables avec les règles suivantes :
- **Policy** : DROP par défaut
- **Loopback** : toujours autorisé
- **Connexions établies** : autorisées
- **SSH** : uniquement depuis les réseaux admin (192.168.1.0/24, 192.168.10.0/24)
- **HTTP/HTTPS** : ouvert (Traefik)
- **Services admin** (Grafana, Prometheus, Traefik dashboard) : admin uniquement
- **Reste** : DROP avec logging

## DNS

- Domaine principal : `mounik.ovh`
- Fournisseur DNS : Cloudflare
- Tous les services sont exposés via des sous-domaines `*.mounik.ovh`
- Cloudflare Tunnel redirige le trafic vers Traefik (pas d'ouverture de ports)

### Sous-domaines

```
*.mounik.ovh  →  Cloudflare Tunnel  →  Traefik  →  Service
```

| Sous-domaine               | IP destination      | VLAN | Port |
|----------------------------|---------------------|------|------|
| `tinyauth.mounik.ovh`      | 192.168.20.100      | 20   | 443  |
| `vaultwarden.mounik.ovh`   | 192.168.20.100      | 20   | 443  |
| `paperless.mounik.ovh`     | 192.168.30.100      | 30   | 443  |
| `immich.mounik.ovh`        | 192.168.30.101      | 30   | 443  |
| `nextcloud.mounik.ovh`     | 192.168.30.102      | 30   | 443  |
| `mealie.mounik.ovh`        | 192.168.30.103      | 30   | 443  |
| `actual.mounik.ovh`        | 192.168.30.104      | 30   | 443  |
| `obsidian.mounik.ovh`      | 192.168.30.105      | 30   | 443  |
| `grafana.mounik.ovh`       | 192.168.20.101      | 20   | 443  |
| `traefik.mounik.ovh`       | 192.168.20.100      | 20   | 443  |
| `gitea.mounik.ovh`         | 192.168.20.102      | 20   | 443  |
| `harbor.mounik.ovh`        | 192.168.20.103      | 20   | 443  |
| `wazuh.mounik.ovh`         | 192.168.20.104      | 20   | 443  |
| `ollama.mounik.ovh`        | 192.168.40.100      | 40   | 443  |
| `openwebui.mounik.ovh`     | 192.168.40.101      | 40   | 443  |
| `n8n.mounik.ovh`           | 192.168.40.102      | 40   | 443  |

## Flux réseau

```
Utilisateur
    |
    v
Internet
    |
    v
Freebox (NAT)
    |
    v
Cloudflare Tunnel (pas d'ouverture de ports)
    |
    v
Traefik (VLAN 20)
    |
    v
TinyAuth (auth centralisée)
    |
    v
CrowdSec (IDS/IPS - analyse logs)
    |
    v
Services (VLAN 30/40)
```
