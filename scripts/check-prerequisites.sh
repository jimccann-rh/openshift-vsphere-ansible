#!/bin/bash
# Check prerequisites before running the playbook

set -e

echo "Checking prerequisites..."

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "ERROR: Ansible is not installed"
    exit 1
fi
echo "✓ Ansible is installed: $(ansible --version | head -n1)"

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    exit 1
fi
echo "✓ Python 3 is installed: $(python3 --version)"

# Check if required Python packages are installed
if ! python3 -c "import pyvmomi" 2>/dev/null; then
    echo "WARNING: pyvmomi Python package is not installed"
    echo "  Install with: pip3 install pyvmomi"
fi

# Check if pull secret exists
if [ ! -f ~/.openshift/pull-secret.json ]; then
    echo "WARNING: Pull secret not found at ~/.openshift/pull-secret.json"
    echo "  Download from: https://console.redhat.com/openshift/install/pull-secret"
fi

# Check if SSH key exists
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "WARNING: SSH public key not found at ~/.ssh/id_rsa.pub"
    echo "  Generate with: ssh-keygen -t rsa -b 4096"
fi

# Check if group_vars/all.yml exists
if [ ! -f group_vars/all.yml ]; then
    echo "ERROR: group_vars/all.yml not found"
    exit 1
fi
echo "✓ Configuration file exists: group_vars/all.yml"

echo ""
echo "Prerequisites check completed!"
