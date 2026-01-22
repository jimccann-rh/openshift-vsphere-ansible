# Changelog

## [Unreleased]

### Added
- **vCenter SSL Certificate Installation**: New role `vcenter_ssl_cert` that automatically downloads and installs vCenter SSL certificates to the system trust store
  - Supports RHEL/CentOS/Fedora, Ubuntu/Debian, and SUSE Linux
  - Automatically detects operating system and uses appropriate certificate store location
  - Updates system certificate trust store after installation
  - Verifies certificate installation
  - Configurable via `vcenter_ssl.enabled` and `vcenter_ssl.port` in `group_vars/all.yml`
  - Can be run independently with `--tags vcenter_ssl`
  - Integrated into main installation playbook to run before vSphere operations

### Features
- OS-specific certificate installation paths:
  - RHEL/CentOS: `/etc/pki/ca-trust/source/anchors/` with `update-ca-trust`
  - Ubuntu/Debian: `/usr/local/share/ca-certificates/` with `update-ca-certificates`
  - SUSE: `/etc/pki/trust/anchors/` with `update-ca-certificates`
- Generic fallback for unsupported operating systems
- Certificate verification after installation
- Automatic cleanup of temporary certificate files

### Documentation
- Added comprehensive README for `vcenter_ssl_cert` role
- Updated main README with SSL certificate configuration section
- Added troubleshooting section for SSL certificate issues
