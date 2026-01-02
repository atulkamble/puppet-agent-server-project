# 🚀 Puppet Deployment Guide

## 🏗️ Infrastructure Setup

### Instance Configuration
- **Instance Type**: t3.medium
- **Key Pair**: puppet.pem  
- **Security Group**: Allow ports 8140, 22, 80

### Server Instance (Puppet Master)
- **Instance ID**: i-0d58a7d3956e6d4f9
- **Public IP**: 34.230.29.197
- **Private IP**: 172.31.24.198
- **Role**: Puppet Server

### Agent Instance
- **Instance ID**: i-0d4b78d801167ee2f  
- **Public IP**: 98.94.87.179
- **Private IP**: 172.31.17.211
- **Role**: Puppet Agent

---

## 📋 Deployment Steps

### Step 1: Setup Puppet Server
SSH into the server instance:
```bash
ssh -i puppet.pem ubuntu@34.230.29.197
```

Upload and run the server setup script:
```bash
./scripts/puppet-server-setup.sh
```

### Step 2: Setup Puppet Agent
SSH into the agent instance:
```bash
ssh -i puppet.pem ubuntu@98.94.87.179
```

Upload and run the agent setup script with server's private IP:
```bash
./scripts/puppet-agent-setup.sh 172.31.24.198
```

### Step 3: Certificate Management
On the **Puppet Server** (172.31.24.198):

1. List pending certificates:
```bash
sudo /opt/puppetlabs/bin/puppetserver ca list
```

2. Sign all certificates:
```bash
sudo /opt/puppetlabs/bin/puppetserver ca sign --all
```

### Step 4: Test Configuration
On the **Puppet Agent** (172.31.17.211):

1. Run puppet agent:
```bash
sudo /opt/puppetlabs/bin/puppet agent -t
```

2. Verify Apache installation:
```bash
systemctl status apache2
curl http://localhost
```

### Step 5: Validate Deployment
Run the validation script on the agent:
```bash
./scripts/validate-deployment.sh
```

---

## 🎯 Expected Results

After successful deployment:
- ✅ Apache2 installed on agent instance
- ✅ Apache2 service running  
- ✅ Custom index.html with "Apache managed by Puppet Server"
- ✅ Puppet agent connected and configured
- ✅ All certificates signed and trusted

---

## 🔧 Troubleshooting Commands

### On Puppet Server:
```bash
# Check server status
sudo systemctl status puppetserver

# View server logs
sudo journalctl -u puppetserver -f

# List all certificates
sudo /opt/puppetlabs/bin/puppetserver ca list --all
```

### On Puppet Agent:
```bash
# Check agent status
systemctl status puppet

# View agent logs
sudo journalctl -u puppet -f

# Manual agent run
sudo /opt/puppetlabs/bin/puppet agent -t --verbose
```

---

## 🌐 Web Access

After deployment, you can access the Apache server at:
- **http://98.94.87.179** (Agent's public IP)

The page should display: "Apache managed by Puppet Server"