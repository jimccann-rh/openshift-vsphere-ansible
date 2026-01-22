#!/bin/bash
# Helper script to create VMs in vSphere for OpenShift UPI installation
# This script can be used as an alternative to Ansible VM provisioning

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Source configuration (if available)
if [ -f "$PROJECT_DIR/group_vars/all.yml" ]; then
    echo "Note: This script requires manual configuration or use Ansible playbooks"
fi

echo "OpenShift vSphere VM Creation Helper"
echo "===================================="
echo ""
echo "This script is a placeholder for VM creation."
echo "For automated VM provisioning, use the Ansible playbooks:"
echo "  ansible-playbook playbooks/install-openshift.yml --tags provision"
echo ""
echo "For manual VM creation, follow these steps:"
echo "1. Use vSphere Web Client or PowerCLI to create VMs"
echo "2. Configure VM settings (CPU, memory, disk, network)"
echo "3. Attach ignition files via CD-ROM or other method"
echo "4. Power on VMs"
echo ""
echo "See README.md for detailed instructions."
