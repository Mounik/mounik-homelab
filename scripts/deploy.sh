#!/usr/bin/env bash
# =============================================================================
# deploy.sh - Script de déploiement mounik-homelab
# Orchestre OpenTofu + Ansible
# Usage: ./scripts/deploy.sh [command]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$ROOT_DIR/terraform"
ANSIBLE_DIR="$ROOT_DIR/ansible"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- Vérifications préalables ---
check_deps() {
    local deps=("tofu" "ansible" "ssh-keygen")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error "Dépendance manquante: $dep"
        fi
    done
    success "Toutes les dépendances sont installées"
}

# --- Clé SSH ---
setup_ssh() {
    local key_file="$HOME/.ssh/mounik-homelab"
    if [ ! -f "$key_file" ]; then
        log "Génération de la clé SSH..."
        ssh-keygen -t ed25519 -C "mounik-homelab" -f "$key_file" -N ""
        success "Clé SSH générée: $key_file"
        echo ""
        echo "Ajoute cette clé sur tes nœuds Proxmox:"
        echo "  ssh-copy-id -i $key_file.pub root@192.168.1.20"
        echo "  ssh-copy-id -i $key_file.pub root@192.168.1.21"
        echo "  ssh-copy-id -i $key_file.pub root@192.168.1.22"
        echo ""
    else
        success "Clé SSH existante: $key_file"
    fi
}

# --- Initialiser OpenTofu ---
init() {
    log "Initialisation d'OpenTofu..."
    cd "$TERRAFORM_DIR"
    tofu init
    success "OpenTofu initialisé"
}

# --- Planifier ---
plan() {
    log "Planification du déploiement..."
    cd "$TERRAFORM_DIR"
    tofu plan -out=tfplan
    success "Plan généré: tofu/plan"
}

# --- Appliquer ---
apply() {
    log "Déploiement des VMs..."
    cd "$TERRAFORM_DIR"
    tofu apply tfplan
    success "VMs déployées"
}

# --- Générer l'inventaire Ansible ---
generate_inventory() {
    log "Génération de l'inventaire Ansible..."
    cd "$TERRAFORM_DIR"
    tofu output -raw ansible_inventory > /dev/null 2>&1 || true
    if [ -f "$ANSIBLE_DIR/inventory-generated.yml" ]; then
        success "Inventaire généré"
    else
        warn "Inventaire non trouvé, vérifie tofu output"
    fi
}

# --- Configurer les VMs ---
configure() {
    log "Configuration des VMs avec Ansible..."
    cd "$ROOT_DIR"

    local inventory="$ANSIBLE_DIR/inventory-generated.yml"
    if [ ! -f "$inventory" ]; then
        inventory="$ANSIBLE_DIR/inventory.yml"
        warn "Inventaire généré non trouvé, utilisation de inventory.yml"
    fi

    ansible-playbook -i "$inventory" "$ANSIBLE_DIR/playbook.yml" "$@"
    success "VMs configurées"
}

# --- Déployer complet ---
deploy() {
    log "=== Déploiement complet mounik-homelab ==="
    echo ""

    check_deps
    setup_ssh
    init
    plan
    apply
    generate_inventory
    configure

    echo ""
    success "=== Déploiement terminé ==="
    echo ""
    echo "Services disponibles via https://*.mounik.ovh"
    echo ""
}

# --- Destruction ---
destroy() {
    warn "Cette action va détruire toutes les VMs!"
    read -p "Continuer? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        cd "$TERRAFORM_DIR"
        tofu destroy -auto-approve
        success "VMs détruites"
    else
        warn "Annulé"
    fi
}

# --- Status ---
status() {
    log "=== État de l'infrastructure ==="
    cd "$TERRAFORM_DIR"
    tofu state list 2>/dev/null || warn "Aucun état trouvé"
    echo ""
    log "=== IPs des VMs ==="
    tofu output -json vm_ips 2>/dev/null | jq -r 'to_entries[] | "\(.key): \(.value)"' || warn "Pas d'IPs disponibles"
}

# --- Menu ---
case "${1:-help}" in
    init)       init ;;
    plan)       plan ;;
    apply)      apply ;;
    configure)  configure ;;
    deploy)     deploy ;;
    destroy)    destroy ;;
    status)     status ;;
    help|*)
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  init        Initialiser OpenTofu"
        echo "  plan        Planifier le déploiement"
        echo "  apply       Appliquer le plan"
        echo "  configure   Configurer les VMs avec Ansible"
        echo "  deploy      Déploiement complet (init + plan + apply + configure)"
        echo "  destroy     Détruire toutes les VMs"
        echo "  status      Afficher l'état de l'infrastructure"
        echo "  help        Afficher cette aide"
        ;;
esac
