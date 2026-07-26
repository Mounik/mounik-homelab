# Services — Guide Complet

## Vue d'ensemble

Le Mounik Personal Cloud Platform héberge **17 services** organisés en 4 catégories. Chaque service a un rôle précis et remplace un service cloud externe.

---

## Vie quotidienne

Ces services remplacent les applications que tu utilises tous les jours.

### Vaultwarden — Gestionnaire de mots de passe

**Ce que c'est :** Un gestionnaire de mots de passe auto-hébergé (alternative à 1Password, Bitwarden).

**Pourquoi ?**
- Tu as 100+ comptes en ligne avec des mots de passe différents
- Vaultwarden les stocke de façon chiffrée chez toi
- Tu n'as plus besoin de retenir tes mots de passe
- Synchronisation sur tous tes appareils

**Sous-domaine :** `vaultwarden.mounik.ovh`
**Technologie :** Rust, Docker, port 8222

---

### Paperless-ngx — Documents administratifs

**Ce que c'est :** Un scanner et un organisateur de documents. Tu photographies un papier, il le classe automatiquement.

**Pourquoi ?**
- Adieu les papiers qui s'accumulent sur la table
- Recherche plein texte dans tous tes documents
- Classification automatique par catégorie
- OCR (reconnaissance de texte sur les photos)

**Sous-domaine :** `paperless.mounik.ovh`
**Technologie :** Python, Docker, port 8000

---

### Immich — Photos personnelles

**Ce que c'est :** Unalbum photo auto-hébergé (alternative à Google Photos).

**Pourquoi ?**
- Tes photos restent chez toi, pas chez Google
- Reconnaissance faciale et de lieux
- Synchronisation automatique depuis ton téléphone
- Interface web et application mobile

**Sous-domaine :** `immich.mounik.ovh`
**Technologie :** TypeScript, Docker, port 2283

---

### Twenty CRM — Contacts et candidatures

**Ce que c'est :** Un CRM (Customer Relationship Management) pour gérer tes contacts et suivre tes candidatures d'emploi.

**Pourquoi ?**
- Centraliser tes contacts professionnels
- Suivre l'avancement de tes candidatures
- Gérer tes opportunités d'emploi
- Alternative open source à Salesforce/HubSpot

**Sous-domaine :** `twenty.mounik.ovh`
**Technologie :** TypeScript, PostgreSQL, Redis, Docker

---

### Actual Budget — Gestion financière

**Ce que c'est :** Un outil de budgétisation personnelle (alternative à YNAB).

**Pourquoi ?**
- Savoir exactement où va ton argent
- Planifier tes dépenses et économies
- Synchronisation avec tes comptes bancaires
- Interface simple et intuitive

**Sous-domaine :** `actual.mounik.ovh`
**Technologie :** JavaScript, SQLite, Docker, port 5006

---

### Nextcloud — Cloud personnel

**Ce que c'est :** Un cloud personnel (alternative à Google Drive, iCloud).

**Pourquoi ?**
- Tes fichiers restent chez toi
- Synchronisation sur tous tes appareils
- Partage de fichiers avec d'autres personnes
- Applications complémentaires (calendrier, contacts, etc.)

**Sous-domaine :** `nextcloud.mounik.ovh`
**Technologie :** PHP, Docker, port 443

---

## Développement

Ces services sont destinés au développement logiciel et au DevOps.

### GitLab CE — Forge logicielle

**Ce que c'est :** Une forge logicielle complète (alternative à GitHub, GitLab.com).

**Pourquoi ?**
- Héberger ton code source en local
- CI/CD intégré (tests automatiques)
- Gestion des issues et des merge requests
- Registry Docker intégré

**Sous-domaine :** `gitlab.mounik.ovh`
**Technologie :** Ruby, PostgreSQL, Kubernetes

---

### ArgoCD — Déploiement continu

**Ce que c'est :** Un outil de GitOps qui déploie automatiquement tes applications quand tu pousses du code.

**Pourquoi ?**
- Déploiement continu sans intervention manuelle
- Rollback facile en cas de problème
- Historique de tous les déploiements
- Interface web pour visualiser l'état

**Sous-domaine :** `argocd.mounik.ovh`
**Technologie :** Go, Kubernetes

---

### Harbor — Registry Docker

**Ce que c'est :** Un registry privé pour stocker tes images Docker (alternative à Docker Hub).

**Pourquoi ?**
- Stocker tes images Docker en local
- Scan de sécurité automatique (Trivy)
- Gestion des accès et des namespaces
- Réplication entre registres

**Sous-domaine :** `harbor.mounik.ovh`
**Technologie :** Go, PostgreSQL, Redis, Kubernetes

---

## Intelligence artificielle

Ces services permettent d'utiliser l'IA de manière sécurisée.

### Ollama — Proxy API IA

**Ce que c'est :** Un proxy qui centralise les appels aux API d'IA (OpenAI, Anthropic, Mistral).

**Pourquoi ?**
- Une seule interface pour plusieurs fournisseurs d'IA
- Gestion des clés API sécurisée
- Cache des réponses pour réduire les coûts
- Monitoring des appels

**Sous-domaine :** `ollama.mounik.ovh`
**Technologie :** Go, Docker, port 11434

---

### OpenWebUI — Interface de chat IA

**Ce que c'est :** Une interface web pour discuter avec l'IA (comme ChatGPT, mais en local).

**Pourquoi ?**
- Interface familiar pour les utilisateurs de ChatGPT
- Historique des conversations
- Support du RAG (recherche dans tes documents)
- Multi-modèles (OpenAI, Anthropic, etc.)

**Sous-domaine :** `openwebui.mounik.ovh`
**Technologie :** Python, Docker, port 3000

---

### LangGraph — Agent IA

**Ce que c'est :** Un framework pour créer des agents IA intelligents qui peuvent accomplir des tâches complexes.

**Pourquoi ?**
- Créer un assistant DevOps qui peut gérer l'infrastructure
- Automatiser des workflows complexes
- Intégrer plusieurs sources de données
- Exécuter des actions en toute autonomie

**Technologie :** Python, Docker

---

### n8n — Automatisation

**Ce que c'est :** Un outil d'automatisation visuel (alternative à Zapier, Make).

**Pourquoi ?**
- Connecter tes applications entre elles
- Automatiser les tâches répétitives
- Créer des workflows sans code
- Intégrer l'IA dans tes automatisations

**Sous-domaine :** `n8n.mounik.ovh`
**Technologie :** TypeScript, Docker, port 5678

---

### Qdrant — Base vectorielle

**Ce que c'est :** Une base de données spécialisée dans le stockage de vecteurs (pour le RAG).

**Pourquoi ?**
- Indexer tes documents pour la recherche sémantique
- Permettre à l'IA de chercher dans tes notes
- Recherche ultra-rapide dans de gros volumes
- Alternative open source à Pinecone/Weaviate

**Technologie :** Rust, Docker, port 6333

---

## Sécurité & Monitoring

Ces services surveillent et protègent l'infrastructure.

### Traefik — Reverse proxy

**Ce que c'est :** Un guichet d'accueil qui reçoit toutes les requêtes web et les redirige vers le bon service.

**Pourquoi ?**
- Gérer automatiquement les certificats SSL/TLS
- Rediriger le trafic vers le bon service
- Fonctionner avec CrowdSec pour la sécurité
- Interface web pour visualiser le trafic

**Sous-domaine :** `traefik.mounik.ovh`
**Technologie :** Go, Docker, port 80/443

---

### TinyAuth — Authentification

**Ce que c'est :** Un service d'authentification centralisée (alternative à Authelia).

**Pourquoi ?**
- Un seul mot de passe pour tous les services
- Comptes locaux + OAuth (GitHub)
- Léger (~50 Mo de RAM)
- Facile à configurer

**Sous-domaine :** `tinyauth.mounik.ovh`
**Technologie :** Go, Docker, port 3000

---

### CrowdSec — IDS/IPS collaboratif

**Ce que c'est :** Un système de détection d'intrusion qui analyse les logs et bannit les IPs suspectes.

**Pourquoi ?**
- Détecter les attaques en temps réel
- Bannir automatiquement les IPs malveillantes
- Partager les menaces avec la communauté
- Protéger contre le brute force et les scans

**Technologie :** Go, Docker

---

### Prometheus + Grafana — Monitoring

**Ce que c'est :** Des outils de surveillance qui collectent et affichent les métriques de ton infrastructure.

**Pourquoi ?**
- Savoir si tes serveurs fonctionnent correctement
- Détecter les problèmes avant qu'ils n'impactent les utilisateurs
- Visualiser les tendances (CPU, RAM, disque)
- Recevoir des alertes en cas de problème

**Sous-domaine :** `grafana.mounik.ovh`
**Technologie :** Go, Docker, ports 9090 (Prometheus), 3000 (Grafana)

---

### Wazuh — SIEM

**Ce que c'est :** Un système de gestion des événements de sécurité (SIEM).

**Pourquoi ?**
- Détecter les intrusions avancées
- Vérifier la conformité (PCI DSS, GDPR)
- Corréler les événements suspects
- Centraliser les logs de sécurité

**Sous-domaine :** `wazuh.mounik.ovh`
**Technologie :** C, Python, Kubernetes

---

## Tableau récapitulatif

| Catégorie | Service | Sous-domaine | Remplace |
|-----------|---------|--------------|----------|
| **Vie quotidienne** | Vaultwarden | `vaultwarden.mounik.ovh` | 1Password, Bitwarden |
| | Paperless-ngx | `paperless.mounik.ovh` | Scanner papier |
| | Immich | `immich.mounik.ovh` | Google Photos |
| | Twenty CRM | `twenty.mounik.ovh` | Salesforce, HubSpot |
| | Actual Budget | `actual.mounik.ovh` | YNAB |
| | Nextcloud | `nextcloud.mounik.ovh` | Google Drive, iCloud |
| **Développement** | GitLab CE | `gitlab.mounik.ovh` | GitHub, GitLab.com |
| | ArgoCD | `argocd.mounik.ovh` | DeployBot |
| | Harbor | `harbor.mounik.ovh` | Docker Hub |
| **Intelligence artificielle** | Ollama | `ollama.mounik.ovh` | API multiples |
| | OpenWebUI | `openwebui.mounik.ovh` | ChatGPT |
| | LangGraph | — | — |
| | n8n | `n8n.mounik.ovh` | Zapier, Make |
| | Qdrant | — | Pinecone, Weaviate |
| **Sécurité & Monitoring** | Traefik | `traefik.mounik.ovh` | Nginx, HAProxy |
| | TinyAuth | `tinyauth.mounik.ovh` | Authelia |
| | CrowdSec | — | Fail2Ban |
| | Prometheus + Grafana | `grafana.mounik.ovh` | Datadog |
| | Wazuh | `wazuh.mounik.ovh` | Splunk |
