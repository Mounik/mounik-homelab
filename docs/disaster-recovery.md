# Disaster Recovery - mounik-homelab

## Stratégie de sauvegarde

### Règle 3-2-1

- **3** copies des données
- **2** supports différents
- **1** copie externe (disque dur physique à domicile)

### Couvertures

| Type de donnée | Sauvegarde | Fréquence | Rétention |
|----------------|------------|-----------|-----------|
| Configuration VMs | Proxmox Backup Server | Hebdomadaire | 30 jours |
| Données applicatives | restic → disque dur externe | Quotidienne | 90 jours |
| Configuration OpenTofu | Git | Push | Illimitée |
| Manifests Kubernetes | Git (GitLab) | Push | Illimitée |
| Secrets | Vaultwarden | Réplication intégrée | Illimitée |
| PVs Kubernetes | Longhorn snapshots | Quotidienne | 30 jours |

## Composants

### Proxmox Backup Server (PBS)

Sauvegarde des VMs et conteneurs :

```bash
# Installation
apt install proxmox-backup-server

# Sauvegarde VM
vzdump 100 --storage local-backup --compress zstd

# Restauration
qmrestore /mnt/backup/vzdump-qemu-100-*.vma.zst 100
```

### restic

Sauvegarde chiffrée vers disque dur externe :

```bash
# Initialisation
export RESTIC_REPOSITORY=/mnt/backup/restic
export RESTIC_PASSWORD_FILE=/etc/restic/password
restic init

# Sauvegarde
restic backup /opt/docker /etc/traefik /etc/crowdsec

# Restauration
restic restore latest --target /restore
```

### Cloud-init

Configuration reproductible des VMs :

```bash
# Template Debian 13
qm create 9000 --name debian-template --memory 2048
qm set 9000 --scsi0 local-lvm:0
qm set 9000 --ide2 local:iso/debian-13.iso,media=cdrom
qm set 9000 --ciuser admin --cipassword hash
qm template 9000
```

## Procédures de restauration

### VM complète

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

### Données applicatives

```bash
# 1. Monter le repository
export RESTIC_REPOSITORY=/mnt/backup/restic
export RESTIC_PASSWORD_FILE=/etc/restic/password

# 2. Lister les snapshots
restic snapshots

# 3. Restaurer
restic restore <snapshot-id> --target /restore --include /opt/docker/nextcloud

# 4. Copier les données
cp -r /restore/opt/docker/nextcloud /opt/docker/nextcloud
```

### Configuration Ansible

```bash
# 1. Réappliquer la configuration
ansible-playbook -i inventory.yml playbook.yml --tags traefik

# 2. Ou un rôle spécifique
ansible-playbook -i inventory.yml playbook.yml --tags crowdsec

# 3. Redéployer le cluster k3s
ansible-playbook -i inventory.yml playbook.yml --tags k3s

# 4. Redéployer GitLab
ansible-playbook -i inventory.yml playbook.yml --tags gitlab

# 5. Redéployer ArgoCD
ansible-playbook -i inventory.yml playbook.yml --tags argocd
```

### Cluster Kubernetes

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

## Scénarios de reprise

### Perte d'un nœud

1. Les VMs sont réparties sur 3 nœuds
2. Proxmox clustering permet la migration
3. Restaurer les VMs manquantes depuis PBS
4. Réappliquer Ansible

### Perte de toutes les VMs

1. Recréer les VMs avec OpenTofu (`./scripts/deploy.sh apply`)
2. Cloud-init installe Docker
3. Ansible configure les services et le cluster k3s
4. ArgoCD restore les applications Kubernetes
5. Restaurer les données depuis restic

### Perte d'un nœud k3s

1. Le cluster continue de fonctionner (haute disponibilité)
2. Les pods sont reschedulés sur l'autre nœud
3. Restaurer la VM depuis PBS
4. Réinstaller k3s agent : `ansible-playbook -i inventory.yml playbook.yml --tags k3s`
5. Le nœud rejoint automatiquement le cluster

### Perte du disque externe

1. Les VMs sont toujours sur les disques internes
2. Proxmox gère les sauvegardes PBS
3. Seules les données des 90 derniers jours sont perdues
4. Configuration dans Git

## Vérifications

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

## Contacts

| Rôle | Nom | Contact |
|------|-----|---------|
| Administrateur | Mounik | mounik@mounik.ovh |
| Support Cloudflare | - | support@cloudflare.com |
| Support Proxmox | - | https://forum.proxmox.com |
