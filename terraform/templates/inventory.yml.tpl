# Inventaire Ansible généré automatiquement par OpenTofu
# NE PAS MODIFIER MANUELLEMENT - régénérer avec: tofu apply

all:
  children:
    infrastructure:
      hosts:
%{ for name, vm in vms ~}
%{ if vm.role == "infra" ~}
        ${name}:
          ansible_host: ${vm.ip}
          ansible_user: mounik
          ansible_python_interpreter: /usr/bin/python3
          pve_node: ${vm.node}
%{ endif ~}
%{ endfor ~}

    applications:
      hosts:
%{ for name, vm in vms ~}
%{ if vm.role == "app" ~}
        ${name}:
          ansible_host: ${vm.ip}
          ansible_user: mounik
          ansible_python_interpreter: /usr/bin/python3
          pve_node: ${vm.node}
%{ endif ~}
%{ endfor ~}

    ai:
      hosts:
%{ for name, vm in vms ~}
%{ if vm.role == "ai" ~}
        ${name}:
          ansible_host: ${vm.ip}
          ansible_user: mounik
          ansible_python_interpreter: /usr/bin/python3
          pve_node: ${vm.node}
%{ endif ~}
%{ endfor ~}

    devops:
      hosts:
%{ for name, vm in vms ~}
%{ if vm.role == "devops" ~}
        ${name}:
          ansible_host: ${vm.ip}
          ansible_user: mounik
          ansible_python_interpreter: /usr/bin/python3
          pve_node: ${vm.node}
%{ endif ~}
%{ endfor ~}

  vars:
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
    ansible_become: yes
