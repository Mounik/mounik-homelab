# Glossaire — Termes Techniques Expliqués

## A

### Actual Budget
**En simple :** Un gestionnaire de budget personnel open source (alternative à YNAB).  
**Analogie :** C'est comme un carnet de chèques intelligent qui catégorise automatiquement tes dépenses.  
**Dans ce projet :** Actual Budget gère les finances personnelles.

---

### API (Application Programming Interface)
**En simple :** C'est un "menu" qui permet à deux logiciels de communiquer entre eux.  
**Analogie :** C'est comme un restaurant : tu n'entre pas dans la cuisine, tu choisis via le menu. L'API est le menu du logiciel.  
**Exemple :** Quand OpenWebUI demande à OpenAI de générer une réponse, il utilise l'API d'OpenAI.

---

### Ansible
**En simple :** Un outil qui configure automatiquement des serveurs. Tu écris une "recette" (playbook) et Ansible l'applique sur tes serveurs.  
**Analogie :** C'est comme un robot cuisinier qui suit tes instructions à la lettre pour préparer le repas.  
**Dans ce projet :** Ansible installe Docker, configure le firewall, et déploye les applications.

---

### ArgoCD
**En simple :** Un outil qui déploie automatiquement tes applications quand tu modifies le code.  
**Analogie :** C'est comme un jardinier automatique qui arrose les plantes quand il détecte que la terre est sèche.  
**Dans ce projet :** ArgoCD surveille GitLab et déploie les applications sur Kubernetes.

---

### Authentik
**En simple :** Un serveur d'authentification SSO (Single Sign-On) open source (alternative à Keycloak).  
**Analogie :** C'est comme un portier qui vérifie ton identité une seule fois et te donne accès à tous les services.  
**Dans ce projet :** Authentik est le SSO enterprise qui remplace TinyAuth (Phase 2).

---

### Alertmanager
**En simple :** Un outil qui reçoit les alertes de Prometheus et les envoie par email (ou d'autres canaux).  
**Analogie :** C'est comme une alarme incendie qui préven les pompiers quand il y a un problème.  
**Dans ce projet :** Alertmanager envoie des alertes par email quand un service est down ou qu'une métrique est anormale.

---

## C

### CI/CD (Continuous Integration / Continuous Deployment)
**En simple :** CI = tester le code automatiquement. CD = déployer automatiquement.  
**Analogie :** CI = le contrôle qualité en usine. CD = la chaîne de montage qui emballe et expédie le produit fini.  
**Dans ce projet :** GitLab CI teste le code, compile les images Docker, et ArgoCD les déploie.

---

### Cloud-init
**En simple :** Un script qui configure automatiquement une VM au premier démarrage.  
**Analogie :** C'est comme une recette de cuisine qui installe tout automatiquement (Docker, firewall, user, etc.).  
**Dans ce projet :** Quand OpenTofu crée une VM, Cloud-init installe Docker et configure le système.

---

### Cloudflare Tunnel
**En simple :** Un tunnel chiffré sortant de ton serveur vers Internet. Aucun port n'est ouvert sur ta box.  
**Analogie :** C'est un passage souterrain secret entre ton château et l'extérieur. Personne ne peut entrer par la porte principale parce qu'elle n'existe pas.  
**Dans ce projet :** Le tunnel sortant évite d'ouvrir des ports sur la Freebox.

---

### Container (Conteneur)
**En simple :** Un logiciel qui isole une application du reste du système. C'est comme une boîte qui contient tout ce dont l'app a besoin.  
**Analogie :** C'est comme un container maritime : il contient tout (marchandise + emballage) et peut être transporté n'importe où.  
**Dans ce projet :** Chaque service (Traefik, Vaultwarden, etc.) tourne dans son propre conteneur Docker.

---

### CrowdSec
**En simple :** Un système de sécurité qui analyse les logs et bannit automatiquement les IPs suspectes.  
**Analogie :** C'est le vigile du château qui surveille les caméras et bannit les personnes suspectes.  
**Dans ce projet :** CrowdSec analyse les logs de Traefik et bloque les attaquants.

---

## D

### Docker
**En simple :** Un outil qui permet de créer et gérer des conteneurs. Chaque application tourne dans son propre conteneur isolé.  
**Analogie :** C'est comme des boîtes de rangement : chaque application a sa propre boîte avec tout ce qu'il lui faut.  
**Dans ce projet :** Docker est utilisé pour faire tourner Traefik, Vaultwarden, Paperless, etc.

---

### Docker Compose
**En simple :** Un fichier YAML qui décrit comment lancer plusieurs conteneurs Docker ensemble.  
**Analogie :** C'est comme une recette de cuisine qui dit "mélange ces 3 ingrédients dans cet ordre".  
**Dans ce projet :** Chaque service a son propre `docker-compose.yml`.

---

### DNS (Domain Name System)
**En simple :** Le "répertoire téléphonique" d'Internet. Il traduit les noms (google.com) en adresses IP (142.250.74.110).  
**Analogie :** C'est comme les Pages Jaunes : tu cherches un nom et tu trouves l'adresse.  
**Dans ce projet :** Cloudflare gère le DNS pour `mounik.ovh`.

---

### DDoS (Distributed Denial of Service)
**En simple :** Une attaque qui inonde un serveur de requêtes pour le faire tomber.  
**Analogie :** C'est comme 10 000 personnes qui appellent le même numéro en même temps : le serveur est saturé.  
**Dans ce projet :** Cloudflare absorbe les attaques DDoS.

---

## F

### Firewall (Pare-feu)
**En simple :** Un gardien de porte qui décide quel trafic est autorisé ou non.  
**Analogie :** C'est comme un videur de boîte de nuit : il laisse entrer les gens autorisés et bloque les autres.  
**Dans ce projet :** nftables est le firewall de chaque VM.

---

## G

### Git
**En simple :** Un outil qui garde l'historique de toutes les modifications du code. Tu peux revenir en arrière si tu casses quelque chose.  
**Analogie :** C'est comme un Google Docs avec historique : tu peux voir qui a modifié quoi et quand.  
**Dans ce projet :** Tout le code est versionné avec Git sur GitLab.

---

### GitOps
**En simple :** Une méthode où Git est la source de vérité. Si tu veux changer quelque chose, tu modifies Git, et l'infrastructure se met à jour automatiquement.  
**Analogie :** C'est comme un plan d'architecte : si tu modifies le plan, le bâtiment se met à jour automatiquement.  
**Dans ce projet :** ArgoCD surveille GitLab et déploie les changements sur Kubernetes.

---

### Grafana
**En simple :** Un outil qui affiche des tableaux de bord visuels avec les métriques collectées par Prometheus.  
**Analogie :** C'est comme un écran de contrôle dans un cockpit d'avion : tu vois tout d'un coup d'œil.  
**Dans ce projet :** Grafana affiche les dashboards de surveillance du homelab (CPU, RAM, disque, containers).

---

## H

### Helm
**En simple :** Un gestionnaire de packages pour Kubernetes. C'est comme apt-get ou npm mais pour K8s.  
**Analogie :** C'est comme un magasin d'applications : tu choisis l'app et Helm l'installe automatiquement.  
**Dans ce projet :** GitLab, ArgoCD et Harbor sont installés via Helm.

---

### HAProxy
**En simple :** Un équilibreur de charge et reverse proxy (similaire à Traefik).  
**Analogie :** C'est comme un standardiste qui distribue les appels entre les opérateurs.  
**Dans ce projet :** Traefik remplace HAProxy.

---

### Harbor
**En simple :** Un registry Docker privé pour stocker tes images (alternative à Docker Hub).  
**Analogie :** C'est comme un entrepôt sécurisé pour tes applications conteneurisées.  
**Dans ce projet :** Harbor stocke les images Docker du cluster Kubernetes.

---

### Home Assistant
**En simple :** Un système de domotique qui connecte tous tes appareils intelligents (alternative à Google Home).  
**Analogie :** C'est comme un cerveau central qui coordonne tous les appareils de ta maison.  
**Dans ce projet :** Home Assistant pilote la lumière, le chauffage, et les automatisations maison.

---

## I

### IaC (Infrastructure as Code)
**En simple :** Décrire ton infrastructure (serveurs, réseau, etc.) dans du code plutôt qu'à la main.  
**Analogie :** C'est comme une recette de cuisine : si tu la suis exactement, tu obtiens le même résultat à chaque fois.  
**Dans ce projet :** OpenTofu décrit les VMs, Ansible décrit la configuration.

---

### IDS/IPS (Intrusion Detection/Prevention System)
**En simple :** Un système qui détecte et bloque les intrusions.  
**Analogie :** C'est comme un alarme anti-effraction qui détecte les mouvements suspects et verrouille les portes.  
**Dans ce projet :** CrowdSec est l'IDS/IPS du homelab.

---

### Immich
**En simple :** Un album photo auto-hébergé (alternative à Google Photos).  
**Analogie :** C'est comme un album photo numérique qui reconnaît les visages et les lieux automatiquement.  
**Dans ce projet :** Immich gère les photos personnelles avec reconnaissance faciale.

---

### JobSync
**En simple :** Un tracker de candidatures d'emploi open source qui centralise toutes tes candidatures en un seul endroit.
**Analogie :** C'est comme un tableur Excel intelligent qui suit l'avancement de tes candidatures et t'alerte sur les délais.
**Dans ce projet :** JobSync gère le suivi des candidatures d'emploi avec automatisation via n8n.

---

## K

### Kubernetes (K8s)
**En simple :** Un système qui orchestre les conteneurs. Il distribue le travail entre les serveurs et gère les applications automatiquement.  
**Analogie :** C'est comme un chef d'orchestre qui dit à chaque musicien quand jouer et comment.  
**Dans ce projet :** k3s (version allégée de K8s) fait tourner GitLab, ArgoCD, Harbor.

---

### k3s
**En simple :** Une distribution légère de Kubernetes, conçue pour les edge computing et les petits clusters.  
**Analogie :** C'est comme Kubernetes en version compact : même fonctionnalités, moins de ressources.  
**Dans ce projet :** k3s fait tourner le cluster Kubernetes sur les nœuds pve02 et pve03.

---

## L

### LangGraph
**En simple :** Un framework pour créer des agents IA autonomes qui peuvent utiliser des outils.  
**Analogie :** C'est comme un assistant intelligent qui peut chercher des infos, envoyer des emails, et prendre des décisions.  
**Dans ce projet :** LangGraph crée des agents IA qui interagissent avec les services.

---

### LDAP (Lightweight Directory Access Protocol)
**En simple :** Un protocole pour gérer les comptes utilisateurs. C'est comme un annuaire d'entreprise.  
**Analogie :** C'est comme le répertoire de contacts de ton téléphone, mais pour les comptes utilisateurs d'une entreprise.  
**Dans ce projet :** Authentik (Phase 2) utilisera LDAP pour gérer les utilisateurs.

---

### Longhorn
**En simple :** Un système de stockage distribué pour Kubernetes. Les données sont réparties entre les serveurs.  
**Analogie :** C'est comme un coffre-fort distribué : les données sont en plusieurs morceaux sur différents serveurs.  
**Dans ce projet :** Longhorn stocke les données des applications Kubernetes.

---

### Loki
**En simple :** Un outil qui agrège les logs (journaux) de tous tes services. C'est l'équivalent de l'ELK Stack mais plus léger.  
**Analogie :** C'est comme une bibliothèque qui range tous les journaux de bord dans des étagères.  
**Dans ce projet :** Loki centralise les logs de tous les services et permet de les chercher via Grafana.

---

## M

### MetalLB
**En simple :** Un équilibreur de charge pour Kubernetes. Il donne des IP publiques aux services K8s.  
**Analogie :** C'est comme un standardiste qui distribue les appels entre les opérateurs.  
**Dans ce projet :** MetalLB expose les services Kubernetes avec des IPs du VLAN 20.

---

### MFA (Multi-Factor Authentication)
**En simple :** Authentification à plusieurs facteurs. Tu dois prouver qui tu es de 2 façons différentes.  
**Analogie :** C'est comme une serrure qui demande à la fois un code ET une empreinte digitale.  
**Dans ce projet :** Authentik (Phase 2) supportera le MFA (TOTP, WebAuthn).

---

## N

### Namespace
**En simple :** Un espace de noms dans Kubernetes qui isole les applications entre elles.  
**Analogie :** C'est comme des appartements dans un immeuble : chaque app a son propre espace.  
**Dans ce projet :** GitLab, ArgoCD, Harbor ont chacun leur namespace.

---

### nftables
**En simple :** Le firewall natif de Linux. Il décide quel trafic est autorisé ou non.  
**Analogie :** C'est comme un gardien de porte qui filtre les visiteurs.  
**Dans ce projet :** Chaque VM a ses propres règles nftables.

---

### Nextcloud
**En simple :** Un cloud personnel (alternative à Google Drive, iCloud).  
**Analogie :** C'est comme un disque dur dans le cloud, mais hébergé chez toi.  
**Dans ce projet :** Nextcloud stocke les fichiers, calendriers, et contacts.

---

### n8n
**En simple :** Un outil d'automatisation de workflows (alternative à Zapier, Make).  
**Analogie :** C'est comme un robot qui connecte tes applications entre elles.  
**Dans ce projet :** n8n automatise les tâches répétitives entre les services.

---

## O

### OAuth2/OIDC
**En simple :** Des protocoles pour s'authentifier via un service tiers (comme "Se connecter avec Google").  
**Analogie :** C'est comme utiliser ta carte d'identité pour entrer dans un bâtiment : tu ne crées pas un nouveau compte, tu utilises celui que tu as déjà.  
**Dans ce projet :** TinyAuth supporte l'OAuth2 (GitHub).

---

### Ollama
**En simple :** Un outil qui fait tourner des modèles d'IA directement sur ton serveur (Llama, Mistral, etc.).  
**Analogie :** C'est comme un traducteur personnel qui parle plusieurs langues, sans besoin d'internet.  
**Dans ce projet :** Ollama fait tourner les modèles d'IA locaux pour le chat et le RAG.

---

### OpenWebUI
**En simple :** Une interface web pour discuter avec l'IA (comme ChatGPT, mais en local).  
**Analogie :** C'est comme une interface de messagerie, mais pour parler à ton IA locale.  
**Dans ce projet :** OpenWebUI est l'interface de chat pour interagir avec Ollama.

---

### OpenTofu
**En simple :** Un fork open source de Terraform. Il crée et gère l'infrastructure (VMs, réseau, etc.) via du code.  
**Analogie :** C'est comme un architecte qui dessine les plans et un constructeur qui les exécute.  
**Dans ce projet :** OpenTofu crée les VMs sur Proxmox.

---

## P

### Playbook
**En simple :** Un fichier YAML qui décrit comment configurer un serveur avec Ansible.  
**Analogie :** C'est comme une recette de cuisine : "installe Docker, configure le firewall, lance le service".  
**Dans ce projet :** `playbook.yml` décrit comment configurer toutes les VMs.

---

### Pod
**En simple :** L'unité de base dans Kubernetes. Un pod contient un ou plusieurs conteneurs qui tournent ensemble.  
**Analogie :** C'est comme une chambre d'hôtel : elle contient tout ce dont un client a besoin (lit, table, chaise).  
**Dans ce projet :** Chaque application Kubernetes tourne dans un ou plusieurs pods.

---

### Paperless-ngx
**En simple :** Un scanner et organisateur de documents (alternative à un scanner papier).  
**Analogie :** C'est comme un assistant qui classe tous tes papiers automatiquement.  
**Dans ce projet :** Paperless-ngx numérise et organise les documents administratifs.

---

### Plex
**En simple :** Un serveur multimédia qui organise et diffuse tes films, séries et musiques.  
**Analogie :** C'est comme Netflix, mais avec ta propre médiathèque.  
**Dans ce projet :** Plex streaming la médiathèque personnelle sur tous les appareils.

---

### Prometheus
**En simple :** Un outil qui collecte les métriques (CPU, RAM, disque, etc.) de tes serveurs et containers.  
**Analogie :** C'est comme un compteur electricité qui mesure la consommation de chaque pièce.  
**Dans ce projet :** Prometheus collecte les métriques de toutes les VMs, containers, et services.

---

### Promtail
**En simple :** Un collecteur de logs qui envoie les logs à Loki.  
**Analogie :** C'est comme un facteur qui ramène le courrier au bureau de poste (Loki).  
**Dans ce projet :** Promtail collecte les logs système et Docker et les envoie à Loki.

---

### Proxmox VE
**En simple :** Un hyperviseur open source qui permet de créer des machines virtuelles (VMs).  
**Analogie :** C'est comme un immeuble qui contient plusieurs appartements (VMs).  
**Dans ce projet :** Proxmox fait tourner les 3 serveurs.

---

### Qdrant
**En simple :** Une base de données vectorielle pour la recherche sémantique (alternative à Pinecone).  
**Analogie :** C'est comme un moteur de recherche qui comprend le sens des mots, pas juste les mots clés.  
**Dans ce projet :** Qdrant stocke les embeddings pour le RAG (recherche dans les documents).

---

## R

### RBAC (Role-Based Access Control)
**En simple :** Un système qui donne des accès selon le rôle de l'utilisateur.  
**Analogie :** C'est comme dans un hôpital : un médecin a plus d'accès qu'une infirmière, qui a plus d'accès qu'un bénévole.  
**Dans ce projet :** Kubernetes utilise RBAC pour contrôler qui peut faire quoi.

---

### Reverse Proxy
**En simple :** Un serveur qui reçoit les requêtes web et les redirige vers le bon service.  
**Analogie :** C'est comme un standardiste : il reçoit l'appel et le transfère à la bonne personne.  
**Dans ce projet :** Traefik est le reverse proxy principal.

---

### restic
**En simple :** Un outil de sauvegarde chiffrée et incrémentale.  
**Analogie :** C'est comme un coffre-fort qui sauvegarde uniquement les changements.  
**Dans ce projet :** restic sauvegarde les données critiques sur le disque externe.

---

## S

### SAML (Security Assertion Markup Language)
**En simple :** Un protocole pour s'authentifier entre différentes applications.  
**Analogie :** C'est comme un visa qui prouve qui tu es dans un autre pays.  
**Dans ce projet :** Authentik (Phase 2) supportera SAML pour le SSO.

---

### SSO (Single Sign-On)
**En simple :** Un seul identifiant/mot de passe pour accéder à tous les services.  
**Analogie :** C'est comme un passe magnétique qui ouvre toutes les portes de l'hôtel.  
**Dans ce projet :** TinyAuth (Phase 1) et Authentik (Phase 2) offrent le SSO.

---

## T

### TinyAuth
**En simple :** Un service d'authentification léger pour Traefik (alternative à Authelia).  
**Analogie :** C'est comme un gardien simple qui vérifie ton identité avant d'entrer.  
**Dans ce projet :** TinyAuth protège l'accès aux services web avec un seul mot de passe.

---

### Twenty CRM
**En simple :** Un CRM open source pour gérer les contacts et candidatures (alternative à Salesforce).  
**Analogie :** C'est comme un carnet de contacts intelligent qui suit tes relations professionnelles.  
**Dans ce projet :** Twenty CRM gère les contacts et les candidatures d'emploi.

---

### Template
**En simple :** Un modèle de VM préconfiguré. Quand tu crées une VM, elle copie le template.  
**Analogie :** C'est comme un moule à gâteau : tu verses la pâte et tu obtiens toujours la même forme.  
**Dans ce projet :** Le template Debian 13 est utilisé pour créer toutes les VMs.

---

### TLS (Transport Layer Security)
**En simple :** Le protocole qui chiffre les communications web (le "https" dans l'URL).  
**Analogie :** C'est comme une enveloppe scellée : personne ne peut lire le contenu en cours de route.  
**Dans ce projet :** TLS est géré par Cloudflare et Traefik.

---

## V

### VLAN (Virtual Local Area Network)
**En simple :** Un réseau virtuel qui isole physiquement les différents types de trafic.  
**Analogie :** C'est comme des pièces fermées à clé dans une maison : chaque pièce a un usage.  
**Dans ce projet :** 4 VLANs (Mgmt, Infra, App, IA) séparent les services.

---

### VM (Virtual Machine)
**En simple :** Un ordinateur virtuel qui tourne à l'intérieur d'un autre ordinateur.  
**Analogie :** C'est comme un appartement dans un immeuble : chaque VM a son propre espace.  
**Dans ce projet :** Chaque service tourne dans sa propre VM.

---

### Vaultwarden
**En simple :** Un gestionnaire de mots de passe auto-hébergé (alternative à 1Password, Bitwarden).  
**Analogie :** C'est comme un coffre-fort numérique qui stocke tous tes mots de passe.  
**Dans ce projet :** Vaultwarden gère les mots de passe de façon chiffrée et synchronisée.

---

## W

### WAF (Web Application Firewall)
**En simple :** Un firewall spécialisé pour les applications web. Il détecte les attaques HTTP.  
**Analogie :** C'est comme un videur qui connaît tous les types de fausses cartes d'identité.  
**Dans ce projet :** CrowdSec AppSec est le WAF du homelab.

---

### Wazuh
**En simple :** Un SIEM qui collecte les logs et détecte les intrusions.  
**Analogie :** C'est comme un centre de sécurité avec des caméras et des alarmes.  
**Dans ce projet :** Wazuh surveille toutes les VMs et détecte les menaces.
