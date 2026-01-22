# vCenter SSL Certificate Role

This role downloads and installs the vCenter SSL certificate to the system trust store, enabling secure connections to vCenter without certificate validation errors.

## Features

- Automatically detects the operating system (RHEL/CentOS, Ubuntu/Debian, SUSE)
- Downloads vCenter SSL certificate using OpenSSL
- Installs certificate to the appropriate system trust store location
- Updates the certificate trust store
- Verifies certificate installation
- Supports custom ports and configuration

## Supported Operating Systems

- **RedHat/CentOS/Fedora**: Uses `/etc/pki/ca-trust/source/anchors/` and `update-ca-trust`
- **Ubuntu/Debian**: Uses `/usr/local/share/ca-certificates/` and `update-ca-certificates`
- **SUSE**: Uses `/etc/pki/trust/anchors/` and `update-ca-certificates`
- **Generic**: Provides manual instructions for other OS types

## Configuration

Configure in `group_vars/all.yml`:

```yaml
vcenter_ssl:
  enabled: true  # Set to false to skip
  port: 443      # vCenter HTTPS port
```

## Usage

The role is automatically included in the main installation playbook and runs after prerequisites validation.

To run only the SSL certificate installation:

```bash
ansible-playbook playbooks/install-openshift.yml --tags vcenter_ssl
```

## How It Works

1. **Certificate Download**: Uses OpenSSL to connect to vCenter and extract the SSL certificate
2. **OS Detection**: Automatically detects the operating system family
3. **Certificate Installation**: Copies certificate to the appropriate system directory
4. **Trust Store Update**: Runs the OS-specific command to update the trust store
5. **Verification**: Verifies the certificate is properly installed

## Troubleshooting

### Certificate Download Fails

- Verify vCenter is reachable: `ping vcenter.example.com`
- Check network connectivity: `telnet vcenter.example.com 443`
- Verify OpenSSL is installed: `openssl version`

### Certificate Not Trusted

- Check certificate was installed: `ls -la /etc/pki/ca-trust/source/anchors/` (RHEL)
- Verify trust store was updated: Check if `update-ca-trust` or `update-ca-certificates` ran successfully
- Test certificate: `openssl s_client -connect vcenter.example.com:443`

### Permission Errors

- Ensure playbook runs with appropriate privileges (sudo/root)
- Check certificate directory permissions

## Security Notes

- The certificate is downloaded over an insecure connection initially (to establish trust)
- Once installed, all subsequent connections will use the trusted certificate
- The temporary certificate file is automatically cleaned up after installation
