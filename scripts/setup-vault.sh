#!/bin/bash
# Setup Ansible Vault for sensitive variables

set -e

VAULT_FILE="group_vars/vault.yml"

if [ ! -f "$VAULT_FILE" ]; then
    echo "Creating Ansible Vault file: $VAULT_FILE"
    cat > "$VAULT_FILE" <<EOF
---
# Ansible Vault encrypted variables
# To edit: ansible-vault edit $VAULT_FILE
# To encrypt: ansible-vault encrypt_string 'value' --name variable_name

vault_vsphere_password: "CHANGE_ME"
EOF
    echo "Vault file created. Please edit it with: ansible-vault edit $VAULT_FILE"
else
    echo "Vault file already exists: $VAULT_FILE"
fi
