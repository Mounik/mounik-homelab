#cloud-config
# Template cloud-init pour les VMs Debian 13 - mounik-homelab

# --- Utilisateur ---
users:
  - name: mounik
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    groups: sudo, docker
    ssh_authorized_keys:
      - ${ssh_public_key}

# --- Network ---
network:
  version: 2
  ethernets:
    ens18:
      dhcp4: false
      addresses:
        - ${ip_address}/24
      gateway4: ${gateway}
      nameservers:
        addresses: ${dns_servers}

# --- Packages ---
package_update: true
package_upgrade: true
packages:
  - curl
  - wget
  - git
  - vim
  - htop
  - net-tools
  - apt-transport-https
  - ca-certificates
  - gnupg
  - lsb-release
  - python3
  - python3-pip
  - openssh-server

# --- SSH ---
ssh_pwauth: false
disable_root: false

# --- Docker ---
runcmd:
  # Installer Docker
  - curl -fsSL https://get.docker.com | sh
  - usermod -aG docker mounik
  # Installer Docker Compose plugin
  - apt-get install -y docker-compose-plugin
  # Activer Docker
  - systemctl enable docker
  - systemctl start docker
  # Nettoyage
  - apt-get clean
  - apt-get autoremove -y
