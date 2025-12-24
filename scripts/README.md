# 🐘 Puppet Agent–Server Project Test Files

This directory contains comprehensive test scripts and automation for the Puppet Agent-Server project.

## 📁 Scripts Overview

### 🔴 `puppet-server-setup.sh`
**Purpose**: Automated Puppet Server installation and configuration
- Installs Puppet Server 7
- Configures memory settings for EC2
- Creates production environment structure
- Sets up Apache deployment manifest
- Starts and enables services

**Usage**:
```bash
chmod +x puppet-server-setup.sh
./puppet-server-setup.sh
```

### 🟢 `puppet-agent-setup.sh`
**Purpose**: Automated Puppet Agent installation and configuration
- Installs Puppet Agent
- Configures agent settings
- Sets up hostname and hosts file
- Initiates certificate request

**Usage**:
```bash
chmod +x puppet-agent-setup.sh
./puppet-agent-setup.sh <PUPPET_SERVER_IP>
```

### 🧪 `test-puppet-setup.sh`
**Purpose**: Comprehensive test suite for both server and agent
- Detects server vs agent automatically
- Tests service status, configuration, and connectivity
- Validates certificates and Apache deployment
- Color-coded pass/fail results

**Usage**:
```bash
chmod +x test-puppet-setup.sh
./test-puppet-setup.sh
```

### 🔍 `validate-deployment.sh`
**Purpose**: End-to-end validation of the complete deployment
- Runs Puppet agent and validates results
- Tests Apache installation and configuration
- Verifies idempotency
- Checks HTTP responses

**Usage** (run on Puppet Agent):
```bash
chmod +x validate-deployment.sh
./validate-deployment.sh
```

## 🚀 Quick Start

1. **Make scripts executable**:
   ```bash
   chmod +x scripts/*.sh
   ./run-project.sh  # View execution guide
   ```

2. **Setup Puppet Server** (EC2 Instance 1):
   ```bash
   ./scripts/puppet-server-setup.sh
   ```

3. **Setup Puppet Agent** (EC2 Instance 2):
   ```bash
   ./scripts/puppet-agent-setup.sh <SERVER_PRIVATE_IP>
   ```

4. **Sign certificates** (on Server):
   ```bash
   sudo /opt/puppetlabs/bin/puppetserver ca sign --all
   ```

5. **Run validation** (on Agent):
   ```bash
   ./scripts/validate-deployment.sh
   ```

## 🧪 Test Categories

### ✅ Server Tests
- Service status and configuration
- Port availability (8140)
- Environment and manifest structure
- Certificate authority setup

### ✅ Agent Tests
- Service configuration
- Server connectivity
- Certificate status
- Apache deployment validation

### ✅ Integration Tests
- End-to-end deployment
- HTTP response validation
- Idempotency verification
- Configuration drift detection

## 📊 Expected Output

### Successful Server Setup
```
🎉 Puppet Server setup complete!
📋 Next steps:
   1. Set up Puppet Agent on the second EC2 instance
   2. Sign certificates when agent requests them
   3. Test the configuration
```

### Successful Agent Setup
```
🎉 Puppet Agent setup complete!
📋 Next steps:
   1. On Puppet Server, run: sudo /opt/puppetlabs/bin/puppetserver ca list
   2. On Puppet Server, run: sudo /opt/puppetlabs/bin/puppetserver ca sign --all
   3. On this agent, run: sudo /opt/puppetlabs/bin/puppet agent -t
```

### Successful Validation
```
🎉 Validation Complete!
📋 Summary:
  - Apache installed and running
  - Custom web page deployed
  - Configuration managed by Puppet
  - Idempotency verified
```

## 🔧 Troubleshooting

### Common Issues
- **Certificate errors**: Check hostname resolution
- **Connection refused**: Verify Security Groups (port 8140)
- **Agent not updating**: Check server logs
- **Apache issues**: Validate manifest syntax

### Debug Commands
```bash
# View Puppet logs
journalctl -u puppetserver -f  # Server
journalctl -u puppet -f       # Agent

# Manual Puppet runs
sudo /opt/puppetlabs/bin/puppet agent -t --verbose

# Certificate management
sudo /opt/puppetlabs/bin/puppetserver ca list --all
```

## 🎯 Success Criteria

✅ Puppet Server running and accessible on port 8140
✅ Agent successfully registered and certificate signed
✅ Apache package installed via Puppet manifest
✅ Apache service running and enabled
✅ Custom index.html deployed with correct content
✅ Web server accessible via HTTP on port 80
✅ Idempotent configuration management working