# OpenShift vSphere Installation with Ansible

This Ansible project automates the installation of OpenShift Container Platform on VMware vSphere infrastructure.

## Overview

This project provides a complete automation solution for installing OpenShift 4.x on vSphere using Ansible playbooks. It handles:

- Prerequisites validation and tool installation
- **vCenter SSL certificate installation** to system trust store
- Install configuration generation
- Manifest and ignition file generation
- VM provisioning in vSphere
- Bootstrap and installation monitoring
- Post-installation verification

## Prerequisites

### System Requirements

- **Control Node**: Linux system (RHEL, CentOS, Fedora, Ubuntu, or Debian) with:
  - Python 3.6 or higher
  - Ansible 2.9 or higher
  - Network access to vSphere vCenter
  - Network access to download OpenShift binaries

### vSphere Requirements

- VMware vSphere 7.0 or higher
- vCenter Server with appropriate permissions
- RHEL 8 template configured in vSphere
- Network configuration (DHCP or static IP assignment)
- DNS resolution for cluster domain
- Sufficient resources (CPU, memory, storage)

### OpenShift Requirements

- Red Hat OpenShift pull secret (download from [Red Hat OpenShift Cluster Manager](https://console.redhat.com/openshift/install/pull-secret))
- SSH public key for cluster access
- Valid base domain for cluster

## Project Structure

```
openshift-vsphere-ansible/
├── ansible.cfg              # Ansible configuration
├── inventory.yml            # Inventory file
├── requirements.yml         # Ansible collection requirements
├── group_vars/
│   └── all.yml             # Main configuration variables
├── playbooks/
│   ├── install-openshift.yml    # Main installation playbook
│   └── destroy-cluster.yml      # Cluster destruction playbook
├── roles/
│   ├── prerequisites/       # Validate and install prerequisites
│   ├── vcenter_ssl_cert/    # Download and install vCenter SSL certificate
│   ├── install_config/      # Generate install-config.yaml
│   ├── generate_manifests/  # Generate OpenShift manifests
│   ├── generate_ignition/   # Generate ignition configs
│   ├── provision_vms/       # Provision VMs in vSphere
│   ├── wait_for_bootstrap/  # Wait for bootstrap completion
│   ├── approve_csrs/        # Approve certificate signing requests
│   ├── wait_for_install/    # Wait for installation completion
│   └── post_install/        # Post-installation tasks
├── scripts/
│   ├── setup-vault.sh      # Setup Ansible Vault
│   └── check-prerequisites.sh  # Check prerequisites
└── README.md               # This file
```

## Quick Start

### 1. Install Ansible Collections

```bash
ansible-galaxy collection install -r requirements.yml
```

### 2. Configure Variables

Edit `group_vars/all.yml` and update the following variables:

```yaml
# Cluster Configuration
cluster_name: "ocp-cluster"
base_domain: "example.com"

# vSphere Configuration
vsphere:
  vcenter: "vcenter.example.com"
  username: "administrator@vsphere.local"
  password: "{{ vault_vsphere_password }}"
  datacenter: "Datacenter"
  cluster: "Cluster"
  datastore: "datastore1"
  network: "VM Network"
  folder: "/Datacenter/vm/OpenShift"
  template: "rhel8-template"

# Node IPs
bootstrap:
  name: "ocp-cluster-bootstrap"
  ip: "192.168.1.10"

masters:
  - name: "ocp-cluster-master-0"
    ip: "192.168.1.11"
  - name: "ocp-cluster-master-1"
    ip: "192.168.1.12"
  - name: "ocp-cluster-master-2"
    ip: "192.168.1.13"

workers:
  - name: "ocp-cluster-worker-0"
    ip: "192.168.1.21"
  - name: "ocp-cluster-worker-1"
    ip: "192.168.1.22"
```

### 3. Setup Ansible Vault

For sensitive variables like vSphere password:

```bash
./scripts/setup-vault.sh
ansible-vault edit group_vars/vault.yml
```

Add your vSphere password:
```yaml
vault_vsphere_password: "your-vsphere-password"
```

### 4. Prepare Pull Secret

Download your pull secret from [Red Hat OpenShift Cluster Manager](https://console.redhat.com/openshift/install/pull-secret) and save it:

```bash
mkdir -p ~/.openshift
# Copy your pull-secret.json to ~/.openshift/pull-secret.json
```

### 5. Generate SSH Key (if needed)

```bash
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
```

### 6. Check Prerequisites

```bash
chmod +x scripts/*.sh
./scripts/check-prerequisites.sh
```

### 7. Run Installation

```bash
# Run full installation
ansible-playbook playbooks/install-openshift.yml

# Or run with specific tags
ansible-playbook playbooks/install-openshift.yml --tags prerequisites,install_config
```

## Installation Process

The installation follows these steps:

1. **Prerequisites** - Validates environment and installs required tools
2. **Install Config** - Generates `install-config.yaml`
3. **Manifests** - Generates OpenShift manifests
4. **Ignition** - Generates ignition configuration files
5. **Provision VMs** - Creates bootstrap, master, and worker VMs in vSphere
6. **Wait for Bootstrap** - Monitors bootstrap process
7. **Approve CSRs** - Approves certificate signing requests
8. **Wait for Install** - Waits for installation to complete
9. **Post Install** - Verifies cluster and displays information

## Configuration Reference

### vSphere Configuration

Key vSphere variables in `group_vars/all.yml`:

- `vsphere.vcenter`: vCenter Server FQDN or IP
- `vsphere.username`: vCenter username
- `vsphere.password`: vCenter password (use vault)
- `vsphere.datacenter`: Datacenter name
- `vsphere.cluster`: Cluster name
- `vsphere.datastore`: Datastore name
- `vsphere.network`: Network/port group name
- `vsphere.folder`: VM folder path
- `vsphere.template`: RHEL template name

### VM Configuration

- `vsphere.vm.cpu`: Number of CPUs per VM
- `vsphere.vm.memory`: Memory in MB
- `vsphere.disk.size`: Disk size in GB
- `vsphere.disk.thin_provisioned`: Use thin provisioning

### Network Configuration

- `network_type`: "OVNKubernetes" or "OpenShiftSDN"
- `network_cidr`: Pod network CIDR
- `service_network_cidr`: Service network CIDR
- `machine_network_cidr`: Machine network CIDR

## Advanced Configuration

### Static IP Assignment

Enable static IP configuration:

```yaml
vsphere:
  ip_config:
    enabled: true
    gateway: "192.168.1.1"
    netmask: "255.255.255.0"
    dns_servers:
      - "8.8.8.8"
      - "8.8.4.4"
```

### Proxy Configuration

If your environment requires a proxy:

```yaml
proxy:
  enabled: true
  http_proxy: "http://proxy.example.com:8080"
  https_proxy: "https://proxy.example.com:8080"
  no_proxy: "localhost,127.0.0.1,.svc,.cluster.local"
```

### API and Ingress VIPs

For high availability, configure VIPs:

```yaml
api_vip: "192.168.1.100"
ingress_vip: "192.168.1.101"
```

### vCenter SSL Certificate

The playbook automatically downloads and installs the vCenter SSL certificate to the system trust store. This ensures secure connections without certificate validation errors.

**Configuration:**

```yaml
vcenter_ssl:
  enabled: true  # Set to false to skip certificate installation
  port: 443      # vCenter HTTPS port (default: 443)
```

**Supported Operating Systems:**
- **RHEL/CentOS/Fedora**: Certificate installed to `/etc/pki/ca-trust/source/anchors/`
- **Ubuntu/Debian**: Certificate installed to `/usr/local/share/ca-certificates/`
- **SUSE**: Certificate installed to `/etc/pki/trust/anchors/`

**To run only SSL certificate installation:**

```bash
ansible-playbook playbooks/install-openshift.yml --tags vcenter_ssl
```

The certificate is automatically downloaded using OpenSSL, installed to the appropriate system location, and the trust store is updated. This happens before any vSphere operations to ensure secure connections.

## Destroying a Cluster

To destroy an existing cluster:

```bash
ansible-playbook playbooks/destroy-cluster.yml
```

**Warning**: This will delete all VMs and cluster resources!

## Troubleshooting

### Common Issues

1. **vSphere Connection Failed**
   - Verify vCenter connectivity
   - Check credentials in vault
   - Ensure network access to vCenter
   - Verify vCenter SSL certificate is installed (check certificate trust store)

2. **Pull Secret Invalid**
   - Verify pull secret JSON is valid
   - Ensure file path is correct in `all.yml`

3. **VM Provisioning Fails**
   - Check template exists in vSphere
   - Verify network and datastore names
   - Ensure sufficient resources

4. **Bootstrap Timeout**
   - Check bootstrap VM is powered on
   - Verify network connectivity
   - Review bootstrap logs in vSphere console

5. **CSR Approval Issues**
   - Ensure API server is accessible
   - Check kubeconfig is generated
   - Verify DNS resolution

6. **vCenter SSL Certificate Issues**
   - Verify OpenSSL is installed: `openssl version`
   - Check vCenter is reachable: `ping vcenter.example.com`
   - Test certificate download: `openssl s_client -connect vcenter.example.com:443`
   - Verify certificate installation: `ls -la /etc/pki/ca-trust/source/anchors/` (RHEL)
   - Check trust store was updated: Review playbook output for `update-ca-trust` or `update-ca-certificates`

### Debugging

Run playbook with increased verbosity:

```bash
ansible-playbook playbooks/install-openshift.yml -vvv
```

Check installation logs:

```bash
# Installation logs are in the work directory
ls -la /tmp/openshift-install-<cluster-name>/
```

View cluster status:

```bash
export KUBECONFIG=/tmp/openshift-install-<cluster-name>/auth/kubeconfig
oc get nodes
oc get clusteroperators
```

## Post-Installation

After successful installation:

1. **Access Cluster Console**
   - URL: `https://console-openshift-console.apps.<cluster-domain>`
   - Username: `kubeadmin`
   - Password: Check `/tmp/openshift-install-<cluster-name>/auth/kubeadmin-password`

2. **Configure kubeconfig**
   ```bash
   export KUBECONFIG=/tmp/openshift-install-<cluster-name>/auth/kubeconfig
   oc get nodes
   ```

3. **Verify Cluster Operators**
   ```bash
   oc get clusteroperators
   ```

## Security Notes

- **Never commit** `group_vars/vault.yml` or pull secrets to version control
- Use Ansible Vault for all sensitive variables
- Store pull secrets securely
- Rotate SSH keys regularly
- Follow OpenShift security best practices

## Support

For issues and questions:

- OpenShift Documentation: https://docs.openshift.com
- Red Hat Support: https://access.redhat.com/support
- Ansible Documentation: https://docs.ansible.com

## License

This project is provided as-is for automation purposes. Ensure compliance with Red Hat OpenShift licensing requirements.

## Contributing

To improve this project:

1. Test changes in a non-production environment
2. Update documentation for new features
3. Follow Ansible best practices
4. Add appropriate error handling

---

**Note**: This automation is based on OpenShift 4.x User-Provisioned Infrastructure (UPI) installation method. Ensure you have proper Red Hat subscriptions and licenses for OpenShift Container Platform.
