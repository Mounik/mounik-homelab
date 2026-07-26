# Disaster Recovery — Sauvegardes et Restauration

## L'analogie

Imagine que tu construis un Lego complexe. La **sauvegarde**, c'est comme prendre des photos à chaque étape. Si tu casses le Lego, tu peux le rebâtir exactement comme avant grâce aux photos.

---

## Stratégie de sauvegarde

### La règle 3-2-1

C'est la règle d'or des sauvegardes, utilisée par les entreprises et les gouvernements :

| Règle | Explication | Dans mon homelab |
|-------|-------------|------------------|
| **3** copies | Trois copies de chaque donnée | Serveur + PBS + disque externe |
| **2** supports | Deux supports différents | NVMe (interne) + SSD (externe) |
| **1** externe | Une copie hors site | Disque dur physique à domicile |

**Pourquoi 3 copies ?**
- Si le serveur tombe en panne → copy 1 est perdue, copy 2 et 3 restent
- Si le disque dur casse → copy 1 et 2 sont perdues, copy 3 reste
- Si un incendie détruit tout → copy 3 (externe) est en sécurité

### Ce qui est sauvegardé

| Type de donnée | Méthode | Fréquence | Rétention | Explication |
|----------------|---------|-----------|-----------|-------------|
| Configuration VMs | Proxmox Backup Server | Hebdomadaire | 30 jours | Les "plans" de tes VMs |
| Données applicatives | restic → disque dur externe | Quotidienne | 90 jours | Tes vraies données (photos, docs, etc.) |
| Configuration OpenTofu | Git | Push | Illimitée | Les "recettes" pour créer les VMs |
| Manifests Kubernetes | Git (GitLab) | Push | Illimitée | Les "plans" pour déployer les apps |
| Secrets | Vaultwarden | Réplication intégrée | Illimitée | Tes mots de passe et clés |
| PVs Kubernetes | Longhorn snapshots | Quotidienne | 30 jours | Les données des apps Kubernetes |

---

## Composants de sauvegarde

### Proxmox Backup Server (PBS)

**C'est quoi ?** PBS sauvegarde les VMs complètes (disque dur + configuration). C'est comme prendre une **image disque** de chaque VM.

**Analogie :** C'est comme photographier chaque pièce de ton Lego à un instant T. Si tu casses le Lego, tu peux le remettre exactement comme avant.

**Commandes :**
```bash
# Sauvegarder une VM
vzdump 100 --storage local-backup --compress zstd

# Restaurer une VM
qmrestore /mnt/backup/vzdump-qemu-100-*.vma.zst 100
```

### restic

**C'est quoi ?** restic est un outil de sauvegarde chiffrée. Il crée des sauvegardes incrémentales (il ne sauvegarde que ce qui a changé).

**Analogie :** C'est comme sauvegarder uniquement les pièces modifiées du Lego, pas tout le modèle à chaque fois.

**Commandes :**
```bash
# Initialiser le repository
export RESTIC_REPOSITORY=/mnt/backup/restic
export RESTIC_PASSWORD_FILE=/etc/restic/password
restic init

# Sauvegarder
restic backup /opt/docker /etc/traefik /etc/crowdsec

# Restaurer
restic restore latest --target /restore
```

### Cloud-init

**C'est quoi ?** Cloud-init configure automatiquement les VMs lors de leur création. C'est comme une **recette de cuisine** qui installe tout automatiquement.

**Analogie :** Au lieu de configurer chaque VM à la main (installer Docker, créer un user, etc.), Cloud-init fait tout automatiquement au premier démarrage.

---

## Procédures de restauration

### Scénario 1 — VM complète perdue

**Situation :** Une VM a été corrompue ou supprimée.

```bash
# 1. Identifier la VM à restaurer
qm list

# 2. Restaurer depuis la sauvegarde
qmrestore /mnt/backup/vzdump-qemu-100-*.vma.zst 100

# 3. Redémarrer
qm start 100

# 4. Vérifier
ssh admin@192.168.20.100
```

**Temps estimé :** 5-15 minutes selon la taille de la VM.

### Scénario 2 — Données applicatives perdues

**Situation :** Tu as accidentellement supprimé des fichiers dans Nextcloud ou Immich.

```bash
# 1. Monter le repository
export RESTIC_REPOSITORY=/mnt/backup/restic
export RESTIC_PASSWORD_FILE=/etc/restic/password

# 2. Lister les sauvegardes disponibles
restic snapshots

# 3. Restaurer les données
restic restore <snapshot-id> --target /restore --include /opt/docker/nextcloud

# 4. Copier les données restaurées
cp -r /restore/opt/docker/nextcloud /opt/docker/nextcloud
```

**Temps estimé :** 2-10 minutes selon la quantité de données.

### Scénario 3 — Configuration Ansible perdue

**Situation :** Tu as modifié un fichier de config et tout est cassé.

```bash
# 1. Réappliquer la configuration
ansible-playbook -i inventory.yml playbook.yml --tags traefik

# 2. Ou un rôle spécifique
ansible-playbook -i inventory.yml playbook.yml --tags crowdsec

# 3. Redéployer le cluster k3s
ansible-playbook -i inventory.yml playbook.yml --tags k3s
```

**Temps estimé :** 10-30 minutes.

### Scénario 4 — Cluster Kubernetes cassé

**Situation :** Le cluster k3s ne répond plus.

```bash
# 1. Vérifier l'état du cluster
kubectl get nodes
kubectl get pods -A

# 2. Restaurer un namespace
kubectl delete namespace <namespace>
kubectl apply -f <manifests>

# 3. Restaurer depuis ArgoCD
argocd app sync <app-name>

# 4. Restaurer des PVs Longhorn
kubectl get volumes -n longhorn-system
```

**Temps estimé :** 15-45 minutes.

---

## Scénarios de reprise complet

### Perte d'un nœud

**Situation :** Un des 3 serveurs tombe en panne physique.

1. Les VMs sont réparties sur 3 nœuds → les autres continuent de fonctionner
2. Proxmox clustering permet la migration automatique
3. Restaurer les VMs manquantes depuis PBS
4. Réappliquer Ansible

**Temps estimé :** 1-2 heures.

### Perte de toutes les VMs

**Situation :** Un incendie ou une panne massive détruit tout.

1. Réinstaller Proxmox sur les 3 serveurs
2. Recréer les VMs avec OpenTofu (`./scripts/deploy.sh apply`)
3. Cloud-init installe Docker automatiquement
4. Ansible configure les services et le cluster k3s
5. ArgoCD restore les applications Kubernetes
6. Restaurer les données depuis restic

**Objectif :** temps de reconstruction < 1 journée.

### Perte du disque externe

**Situation :** Le disque dur de sauvegarde est corrompu.

1. Les VMs sont toujours sur les disques internes → pas de perte immédiate
2. Proxmox gère les sauvegardes PBS sur les disques internes
3. Seules les données des 90 derniers jours sont potentiellement perdues
4. Configuration dans Git → reproductible

---

## Vérifications régulières

### Hebdomadaires

- [ ] Vérifier les sauvegardes PBS
- [ ] Tester restauration d'un fichier avec restic
- [ ] Consulter les logs de sauvegarde

### Mensuelles

- [ ] Test de restauration complète d'une VM
- [ ] Vérification de l'intégrité des sauvegardes (`restic check`)
- [ ] Rotation des sauvegardes PBS

### Trimestrielles

- [ ] Test de reprise complet (scénario perte totale)
- [ ] Mise à jour de la documentation
- [ ] Audit des permissions et secrets

---

## Contacts

| Rôle | Nom | Contact |
|------|-----|---------|
| Administrateur | Mounik | mounik@mounik.ovh |
| Support Cloudflare | — | support@cloudflare.com |
| Support Proxmox | — | https://forum.proxmox.com |
