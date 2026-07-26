# Sécurité — Défense en Profondeur

## L'analogie

Imagine que ta maison est un château fort. La sécurité ne repose pas sur un seul mur, mais sur **7 couches de défense** :  
1. Le fossé (Cloudflare)  
2. Le pont-levis (Cloudflare Tunnel)  
3. La herse (Traefik)  
4. Le garde (CrowdSec)  
5. La serrure de la porte (TinyAuth)  
6. Les murs intérieurs (VLANs + nftables)  
7. Le coffre-fort (chiffrement)

Si un ennemi franchit un mur, les suivants l'attendent encore.

---

## Politique de sécurité

**Principe fondamental :** Aucun service n'est exposé directement sur Internet. Tout le trafic passe par un tunnel sécurisé.

| Règle | Explication |
|-------|-------------|
| Aucun port ouvert | Le tunnel Cloudflare sort de la box, pas vers l'extérieur |
| Auth centralisée | Un seul mot de passe pour tous les services |
| Isolation réseau | Les VLANs séparent les types de trafic |
| Défense en profondeur | 7 couches de protection superposées |
| Sauvegardes chiffrées | Les données sont chiffrées et sauvegardées |
| Mises à jour auto | Les correctifs de sécurité s'installent automatiquement |

---

## Les 7 couches de protection

### Couche 1 — Cloudflare (DDoS + WAF)

**C'est quoi ?**  
Cloudflare est un service qui protège mon site contre les attaques massives (DDoS) et les failles de sécurité (WAF = Web Application Firewall).

**Analogie :**  
C'est le **fossé du château**. Les attaquants doivent d'abord le traverser avant d'atteindre les murs.

**Fonctionnement :**
```
Attaquant → Cloudflare (absorbe l'attaque) → Mon serveur
```

**Pourquoi c'est important ?**  
- Les attaques DDoS envoient des millions de requêtes pour faire tomber le serveur  
- Cloudflare absorbe tout ça et ne laisse passer que le trafic légitime  
- C'est comme un pare-brise qui filtre les débris

---

### Couche 2 — Cloudflare Tunnel (zéro port ouvert)

**C'est quoi ?**  
Un tunnel chiffré qui sort de mon serveur vers Cloudflare. Aucun port n'est ouvert sur ma box Internet.

**Analogie :**  
C'est un **passage souterrain secret** entre le château et l'extérieur. Personne ne peut entrer par la porte principale parce qu'elle n'existe pas.

**Fonctionnement :**
```
Mon serveur ──► Cloudflare ──► Internet
       (sortant)     (entrant)
```

**Pourquoi c'est mieux qu'un port ouvert ?**  
- Si j'ouvre un port (ex: 443), n'importe qui peut essayer de se connecter  
- Avec un tunnel sortant, c'est **moi** qui établis la connexion  
- Résultat : mon serveur est **invisible** sur Internet

---

### Couche 3 — Traefik (reverse proxy)

**C'est quoi ?**  
Traefik est un "guichet d'accueil" qui reçoit toutes les requêtes web et les redirige vers le bon service.

**Analogie :**  
C'est le **portier du château**. Il vérifie l'identité de chaque visiteur et l'envoie dans la bonne direction.

**Fonctionnement :**
```
Utilisateur → Traefik →识别 le sous-domaine → Bon service
```

**Pourquoi c'est nécessaire ?**  
- J'ai 22 services, chacun avec son sous-domaine  
- Traefik gère automatiquement les certificats SSL/TLS  
- Il empêche les attaques de type "header injection"

---

### Couche 4 — CrowdSec (IDS/IPS collaboratif)

**C'est quoi ?**  
CrowdSec est un système de détection d'intrusion qui analyse les logs de Traefik et bannit automatiquement les IPs suspectes.

**Analogie :**  
C'est le **garde du château** qui surveille les mouvements suspects. Si quelqu'un essaie de forcer la porte, il est banni.

**Fonctionnement :**
```
1. Traefik génère des logs (qui a visité quoi)
2. CrowdSec analyse ces logs en temps réel
3. Si une IP est suspecte → elle est bannie
4. Le bouncer firewall la bloque aussi au niveau réseau
```

**Collections actives :**

| Collection | Ce qu'elle détecte |
|-----------|-------------------|
| `crowdsecurity/traefik` | Attaques spécifiques à Traefik |
| `crowdsecurity/http-cve` | Failles de sécurité connues |
| `crowdsecurity/base-http-scenarios` | Attaques HTTP de base |
| `crowdsecurity/sshd` | Tentatives de brute force SSH |
| `crowdsecurity/linux` | Attaques système Linux |
| `crowdsecurity/appsec-generic-rules` | Règles WAF génériques |
| `crowdsecurity/appsec-virtual-patching` | Protection vulnérabilités connues |
| `crowdsecurity/appsec-crs` | OWASP Core Rule Set |

---

### Couche 5 — TinyAuth (authentification centralisée)

**C'est quoi ?**  
TinyAuth est un service d'authentification qui te demande de t'identifier avant d'accéder à n'importe quel service.

**Analogie :**  
C'est la **serrure de la porte d'entrée**. Tu dois présenter ta carte d'identité avant d'entrer.

**Fonctionnement :**
```
Utilisateur → Traefik → TinyAuth (ForwardAuth) → Service
                              │
                              ▼
                         Login / OAuth
                              │
                              ▼
                         Autorisé? → non → 403 Forbidden
                              │
                              oui
                              ▼
                         Service cible
```

**Phase 1 — TinyAuth (actuel) :**  
- Léger (~50 Mo de RAM)  
- Comptes locaux + OAuth (GitHub)  
- ACL basique par application

**Phase 2 — Authentik (futur) :**  
- IAM complet type entreprise  
- SSO, OAuth2/OIDC, SAML, LDAP  
- MFA (TOTP, WebAuthn)  
- Gestion utilisateurs/groupes avancée

---

### Couche 6 — VLANs + nftables (isolation réseau)

**C'est quoi ?**  
Les VLANs créent des réseaux virtuels séparés, et nftables est le firewall local de chaque VM.

**Analogie :**  
Ce sont les **murs intérieurs du château**. Même si quelqu'un entre dans le salon, il ne peut pas accéder à la chambre sans autorisation.

**Règles nftables :**  
- **Policy DROP** : tout est bloqué par défaut  
- **SSH admin uniquement** : seuls les réseaux autorisés peuvent se connecter  
- **HTTP/HTTPS ouvert** : pour Traefik  
- **Tout le reste** : bloqué avec logging

---

### Couche 7 — Chiffrement + sauvegardes

**C'est quoi ?**  
Tes données sont chiffrées (AES-256) et sauvegardées sur un disque externe.

**Analogie :**  
C'est le **coffre-fort du château**. Même si quelqu'un vole le coffre, il ne peut pas l'ouvrir.

**Règle 3-2-1 :**  
- **3** copies des données  
- **2** supports différents (NVMe + disque externe)  
- **1** copie externe (disque dur physique à domicile)

---

## Kubernetes Security

### Network Policies

Isolation des pods au sein du cluster :

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
```

**Analogie :**  
Chaque application dans Kubernetes est dans sa propre **bulle de savon**. Elle ne peut communiquer qu'avec les services explicitement autorisés.

### RBAC (Role-Based Access Control)

Contrôle d'accès basé sur les rôles :
- **GitLab** : accès aux projets
- **ArgoCD** : accès aux déploiements
- **Harbor** : accès aux registres

### Secrets Management

- Secrets Kubernetes chiffrés
- Vaultwarden pour les secrets externes
- Variables d'environnement sensibles via Sealed Secrets

---

## Scan de vulnérabilités

### Trivy + Harbor

Scan automatique des images Docker via Harbor :  
- CVEs connues (failles de sécurité publiées)  
- Secrets exposés (clés API, mots de passe)  
- Configurations incorrectes  
- Intégré au pipeline CI/CD GitLab  
- Scan automatique à chaque push d'image

### Wazuh (SIEM)

SIEM = Security Information and Event Management. C'est un système qui :  
- Collecte les logs de toutes les VMs  
- Détecte les intrusions  
- Vérifie la conformité (PCI DSS, RGPD)  
- Corréle les événements suspects

---

## Mises à jour de sécurité

### unattended-upgrades

Sur Debian, les mises à jour de sécurité critiques s'installent automatiquement :  
- Correctifs de sécurité  
- Installation automatique  
- Redémarrage planifié si nécessaire

---

## Vue d'ensemble de la défense en profondeur

```
Internet
    ↓
Cloudflare (DDoS + WAF) ← Couche 1
    ↓
Cloudflare Tunnel (TLS) ← Couche 2
    ↓
Traefik (reverse proxy) ← Couche 3
    ↓
CrowdSec (IDS/IPS) ← Couche 4
    ↓
TinyAuth (authentification) ← Couche 5
    ↓
nftables (firewall VM) ← Couche 6
    ↓
Application
    ↓
Stockage (chiffré) ← Couche 7
```

---

## Isolation des services

### Docker (pve01)

Chaque service tourne dans son conteneur Docker avec :  
- Réseau Docker isolé  
- Pas de privilèges excessifs  
- Variables d'environnement pour les secrets  
- Volumes montés en lecture seule quand possible

### Kubernetes (pve02+pve03)

- Namespaces par application
- Network Policies entre les namespaces
- Resource Quotas (limite de ressources)
- Pod Security Policies

---

## Pourquoi ce choix de sécurité ?

En milieu professionnel, la sécurité suit le principe de **défense en profondeur** : on ne fait pas confiance à un seul outil, on empile les couches de protection.  
C'est exactement ce que je fais ici :

| Choix | Raison professionnelle |
|-------|----------------------|
| Cloudflare Tunnel | Les entreprises utilisent des tunnels sortants pour éviter d'ouvrir des ports |
| CrowdSec | Les IDS/IPS collaboratifs sont utilisés dans les SOC (Security Operations Center) |
| nftables | C'est le firewall standard de Linux en entreprise |
| TinyAuth/Authentik | L'IAM (Identity and Access Management) est un must en entreprise |
| Trivy + Harbor | Le scan d'images est obligatoire dans les pipelines CI/CD d'entreprise |
| Wazuh | Les SIEM sont utilisés dans les SOC pour la conformité (PCI DSS, GDPR) |
| Kubernetes Security | Network Policies, RBAC et Secrets sont les standards K8s en production |
| VLANs | La segmentation réseau est obligatoire dans les datacenters |
| Chiffrement | AES-256 est le standard de chiffrement utilisé par les banques et gouvernements |
