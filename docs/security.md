# Sécurité - mounik-homelab

## Politique de sécurité

- **Aucun service exposé directement sur Internet** — accès via Cloudflare Tunnel uniquement
- **Authentification centralisée** — TinyAuth (Phase 1) puis Authentik (Phase 2)
- **Isolation réseau** — 4 VLANs (Mgmt, Infra, App, IA)
- **Defense en profondeur** — CrowdSec IDS/IPS + WAF + nftables
- **Sauvegardes chiffrées** — Proxmox Backup Server + disque dur externe

## Couches de protection

### 1. Réseau

#### VLANs

| VLAN | ID  | Sous-réseau      | Usage                  |
|------|-----|------------------|------------------------|
| Mgmt | 10  | 192.168.10.0/24  | Administration         |
| Infra| 20  | 192.168.20.0/24  | Services critiques     |
| App  | 30  | 192.168.30.0/24  | Services personnels    |
| IA   | 40  | 192.168.40.0/24  | Ollama, LangGraph, n8n |

#### Firewall (nftables)

Chaque VM utilise nftables avec :

- **Policy** : DROP par défaut
- **Loopback** : toujours autorisé
- **Connexions établies** : autorisées
- **SSH** : uniquement depuis les réseaux admin (192.168.1.0/24, 192.168.10.0/24)
- **HTTP/HTTPS** : ouvert (Traefik)
- **Services admin** (Grafana, Traefik dashboard) : admin uniquement
- **Reste** : DROP avec logging

### 2. Accès externe

#### Cloudflare Tunnel

- Aucun port ouvert sur le pare-feu
- Trafic chiffré TLS terminé au niveau Cloudflare
- Protection DDoS Cloudflare incluse
- Under Attack Mode activable

#### DNS

- DNS géré par Cloudflare
- Enregistrements `*.mounik.ovh` pointant vers le tunnel
- Proxy activé pour tous les sous-domaines

### 3. Authentification

#### Phase 1 — TinyAuth

Léger et simple pour démarrer :

```
Utilisateur → Traefik → TinyAuth (ForwardAuth) → Service
```

- Portail d'auth web
- Comptes locaux + OAuth (GitHub)
- ACL basique par application
- ~50 Mo RAM

#### Phase 2 — Authentik

Migration vers un IAM complet type entreprise :

- SSO (Single Sign-On)
- OAuth2/OIDC
- SAML
- LDAP
- MFA (TOTP, WebAuthn)
- Gestion utilisateurs/groupes avancée

### 4. Détection d'intrusion

#### CrowdSec

IDS/IPS collaboratif + WAF applicatif :

```
Attaquant → Cloudflare Tunnel → Traefik → CrowdSec Bouncer → LAPI → allow/ban
```

**Fonctionnement :**

1. Traefik génère des logs d'accès (JSON)
2. CrowdSec analyse ces logs en temps réel
3. Le plugin bouncer dans Traefik interroge CrowdSec LAPI
4. Si une IP est bannie → 403 Forbidden
5. Le bouncer firewall bannit l'IP au niveau réseau

**Collections actives :**

| Collection | Rôle |
|-----------|------|
| `crowdsecurity/traefik` | Attaques spécifiques Traefik |
| `crowdsecurity/http-cve` | Détection de CVE HTTP |
| `crowdsecurity/base-http-scenarios` | Scénarios d'attaque HTTP de base |
| `crowdsecurity/sshd` | Protection brute force SSH |
| `crowdsecurity/linux` | Protection système Linux |
| `crowdsecurity/appsec-generic-rules` | WAF règles génériques |
| `crowdsecurity/appsec-virtual-patching` | Protection vulnérabilités connues |
| `crowdsecurity/appsec-crs` | OWASP Core Rule Set |

### 5. Scan de vulnérabilités

#### Trivy

Scan automatique des images Docker :

- CVEs connues
- Secrets exposés
- Configurations incorrectes
- Intégré au pipeline CI/CD

#### Wazuh

SIEM (Security Information and Event Management) :

- Logs d'audit système
- Détection d'intrusion
- Conformité (PCI DSS, GDPR)
- Corrélation d'événements

### 6. Mises à jour

#### unattended-upgrades

Mises à jour de sécurité automatiques sur Debian :

- Correctifs de sécurité critiques
- Installation automatique
- Redémarrage planifié si nécessaire

## Conception de sécurité

### Défense en profondeur

```
Internet
    ↓
Cloudflare (DDoS + WAF)
    ↓
Cloudflare Tunnel (TLS)
    ↓
Traefik (reverse proxy + CrowdSec bouncer)
    ↓
TinyAuth / Authentik (authentification)
    ↓
nftables (firewall VM)
    ↓
Application
    ↓
Stockage (chiffré)
```

### Isolation des services

Chaque service tourne dans son conteneur Docker avec :

- Réseau Docker isolé
- Pas de privileges excessifs
- Variables d'environnement pour les secrets
- Volumes montés en lecture seule quand possible

## Compétences démontrées

Pour les entretiens DevOps/DevSecOps :

- **Cloudflare Tunnel** : zero-trust networking
- **CrowdSec** : IDS/IPS collaboratif
- **nftables** : firewall stateful
- **TinyAuth/Authentik** : IAM et SSO
- **Trivy** : shift-left security
- **Wazuh** : SIEM et conformité
- **VLANs** : segmentation réseau
- **Chiffrement** : données au repos et en transit
