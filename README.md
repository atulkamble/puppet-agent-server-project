# 🐘 Puppet Agent–Server Project on Ubuntu EC2

## 📌 Overview

This project demonstrates a **complete Puppet Agent–Server setup** using **Ubuntu EC2 instances**.
The Puppet Server centrally manages configuration and enforces desired state on Puppet Agent nodes.

The project provisions **Apache Web Server** on an agent node using **Puppet manifests**, showcasing real-world **Infrastructure as Code (IaC)** and **Configuration Management** concepts.

---

## 🏗️ Architecture

```
+-------------------+        Port 8140        +-------------------+
|   Puppet Server   |  <------------------>  |   Puppet Agent    |
|  (Ubuntu EC2)     |   Certificate-based    |  (Ubuntu EC2)     |
|                   |     Communication      |                   |
+-------------------+                         +-------------------+
```

### Key Points

* Centralized control via Puppet Server
* Secure certificate-based authentication
* Declarative configuration
* Idempotent execution

---

## 🎯 Project Objectives

* Install and configure **Puppet Server**
* Install and configure **Puppet Agent**
* Establish secure agent–server communication
* Deploy Apache on agent node
* Manage services and files centrally
* Validate idempotency and state enforcement

---

## 🧰 Prerequisites

### AWS

* 2 EC2 instances
* Ubuntu 20.04 / 22.04 LTS
* Same VPC (recommended)

### Security Group Rules

| Port | Purpose       |
| ---- | ------------- |
| 22   | SSH           |
| 80   | HTTP (Apache) |
| 8140 | Puppet        |

---

## 🖥️ EC2 Instances

| Instance | Role          |
| -------- | ------------- |
| EC2-1    | Puppet Server |
| EC2-2    | Puppet Agent  |

---

## 📂 Directory Structure (Server)

```
/etc/puppetlabs/code/environments/production/
├── manifests/
│   └── site.pp
```

---

## 🔴 Puppet Server Setup

### Install Puppet Server

```bash
sudo apt update
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install -y puppetserver
```

### Configure Memory

```bash
sudo nano /etc/default/puppetserver
```

```ini
JAVA_ARGS="-Xms512m -Xmx512m"
```

### Start Puppet Server

```bash
sudo systemctl start puppetserver
sudo systemctl enable puppetserver
```

---

## 🟢 Puppet Agent Setup

### Install Puppet Agent

```bash
sudo apt update
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install -y puppet-agent
```

### Configure Agent

```bash
sudo nano /etc/puppetlabs/puppet/puppet.conf
```

```ini
[main]
server = puppetserver
environment = production
```

### Hostname Configuration

```bash
hostnamectl set-hostname puppetagent
```

---

## 🔑 Certificate Management

### Trigger Certificate Request (Agent)

```bash
sudo puppet agent -t
```

### Sign Certificate (Server)

```bash
sudo /opt/puppetlabs/bin/puppetserver ca list
sudo /opt/puppetlabs/bin/puppetserver ca sign --all
```

Re-run on agent:

```bash
sudo puppet agent -t
```

---

## 📝 Puppet Manifest

### `site.pp`

```puppet
node 'puppetagent' {

  package { 'apache2':
    ensure => installed,
  }

  service { 'apache2':
    ensure  => running,
    enable  => true,
    require => Package['apache2'],
  }

  file { '/var/www/html/index.html':
    ensure  => file,
    content => "Apache managed by Puppet Server\n",
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
  }

}
```

---

## ▶️ Apply Configuration

On Puppet Agent:

```bash
sudo puppet agent -t
```

Expected output:

```
Notice: Applied catalog in XX seconds
```

---

## 🌐 Verification

Open browser:

```
http://<AGENT_PUBLIC_IP>
```

You should see:

```
Apache managed by Puppet Server
```

---

## 🧪 Validation Commands

```bash
puppet agent --test
puppet resource service apache2
puppet resource package apache2
systemctl status apache2
```

---

## 📚 Key Concepts Demonstrated

* Puppet Agent–Server architecture
* Certificate-based trust model
* Declarative manifests
* Idempotency
* Centralized configuration
* Production environment structure

---

## 🚀 How to Run This Project

### **Option 1: Automated Setup (Recommended)**

1. **Make scripts executable:**
   ```bash
   chmod +x scripts/*.sh run-project.sh
   ```

2. **View execution guide:**
   ```bash
   ./run-project.sh
   ```

3. **Follow the step-by-step instructions displayed**

### **Option 2: Complete Manual Setup**

#### **Step 1: Puppet Server Setup (EC2 Instance 1)**

**1.1 Update system and install Puppet Server:**
```bash
sudo apt update
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install -y puppetserver
```

**1.2 Configure memory settings:**
```bash
sudo nano /etc/default/puppetserver
# Change: JAVA_ARGS="-Xms512m -Xmx512m"
```

**1.3 Set hostname:**
```bash
sudo hostnamectl set-hostname puppetserver
```

**1.4 Create directory structure:**
```bash
sudo mkdir -p /etc/puppetlabs/code/environments/production/manifests
```

**1.5 Create site.pp manifest:**
```bash
sudo nano /etc/puppetlabs/code/environments/production/manifests/site.pp
```
```puppet
node 'puppetagent' {
  package { 'apache2':
    ensure => installed,
  }
  
  service { 'apache2':
    ensure  => running,
    enable  => true,
    require => Package['apache2'],
  }
  
  file { '/var/www/html/index.html':
    ensure  => file,
    content => "Apache managed by Puppet Server - Manual Setup\n",
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    require => Package['apache2'],
  }
}
```

**1.6 Start Puppet Server:**
```bash
sudo systemctl start puppetserver
sudo systemctl enable puppetserver
```

#### **Step 2: Puppet Agent Setup (EC2 Instance 2)**

**2.1 Update system and install Puppet Agent:**
```bash
sudo apt update
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update
sudo apt install -y puppet-agent
```

**2.2 Set hostname:**
```bash
sudo hostnamectl set-hostname puppetagent
```

**2.3 Configure hosts file (replace with actual server IP):**
```bash
echo "<PUPPET_SERVER_PRIVATE_IP> puppetserver" | sudo tee -a /etc/hosts
```

**2.4 Configure Puppet Agent:**
```bash
sudo nano /etc/puppetlabs/puppet/puppet.conf
```
```ini
[main]
server = puppetserver
environment = production

[agent]
report = true
pluginsync = true
```

**2.5 Enable Puppet service:**
```bash
sudo systemctl enable puppet
export PATH=$PATH:/opt/puppetlabs/bin
```

#### **Step 3: Certificate Management**

**3.1 Request certificate (on Agent):**
```bash
sudo /opt/puppetlabs/bin/puppet agent -t
```

**3.2 Sign certificate (on Server):**
```bash
sudo /opt/puppetlabs/bin/puppetserver ca list
sudo /opt/puppetlabs/bin/puppetserver ca sign --all
```

**3.3 Apply configuration (on Agent):**
```bash
sudo /opt/puppetlabs/bin/puppet agent -t
```

#### **Step 4: Manual Validation**

**4.1 Verify Apache installation (on Agent):**
```bash
systemctl status apache2
dpkg -l | grep apache2
ls -la /var/www/html/index.html
```

**4.2 Test web server:**
```bash
curl http://localhost
# Should return: "Apache managed by Puppet Server - Manual Setup"
```

**4.3 Check Puppet resource status:**
```bash
sudo /opt/puppetlabs/bin/puppet resource package apache2
sudo /opt/puppetlabs/bin/puppet resource service apache2
sudo /opt/puppetlabs/bin/puppet resource file /var/www/html/index.html
```

**4.4 Test idempotency:**
```bash
sudo /opt/puppetlabs/bin/puppet agent -t
# Should show no changes on second run
```

### **Step 6: Verify Deployment**

1. **Check Apache status:**
   ```bash
   systemctl status apache2
   curl http://localhost
   ```

2. **Access via web browser:**
   ```
   http://<AGENT_PUBLIC_IP>
   ```
   You should see: "Apache managed by Puppet Server"

---

## 🧪 Testing & Validation

### **Automated Test Suite**
```bash
# Comprehensive testing (detects server vs agent automatically)
./scripts/test-puppet-setup.sh
```

### **End-to-End Validation**
```bash
# Complete deployment validation (run on agent)
./scripts/validate-deployment.sh
```

### **Manual Validation Commands**
```bash
# Test Puppet configuration
sudo /opt/puppetlabs/bin/puppet agent -t

# Check resource status
sudo /opt/puppetlabs/bin/puppet resource package apache2
sudo /opt/puppetlabs/bin/puppet resource service apache2

# View logs
journalctl -u puppet -f          # Agent logs
journalctl -u puppetserver -f    # Server logs
```

---

## 📋 Prerequisites Checklist

- ✅ **2 Ubuntu EC2 instances** (20.04/22.04 LTS)
- ✅ **Security Groups** configured:
  - Port 22 (SSH)
  - Port 80 (HTTP)
  - Port 8140 (Puppet)
- ✅ **Same VPC** (recommended)
- ✅ **SSH access** to both instances

---

## 🔧 Troubleshooting

### **Common Issues**
- **Certificate errors**: Check `/etc/hosts` hostname resolution
- **Connection refused**: Verify Security Group rules for port 8140
- **Agent not updating**: Check Puppet Server logs
- **Apache issues**: Validate manifest syntax in `site.pp`

### **Debug Commands**
```bash
# Verbose Puppet run
sudo /opt/puppetlabs/bin/puppet agent -t --verbose

# Certificate status
sudo /opt/puppetlabs/bin/puppetserver ca list --all

# Test connectivity
telnet <server_ip> 8140
```

---

## 🎯 Expected Results

✅ **Puppet Server** running and accessible on port 8140  
✅ **Agent registered** with signed certificate  
✅ **Apache installed** via Puppet manifest  
✅ **Apache service** running and enabled  
✅ **Custom web page** deployed with Puppet-managed content  
✅ **HTTP access** working on port 80  
✅ **Idempotent** configuration management

---

## 📁 Project Structure

```
puppet-agent-server-project/
├── scripts/
│   ├── puppet-server-setup.sh    # Automated server setup
│   ├── puppet-agent-setup.sh     # Automated agent setup  
│   ├── test-puppet-setup.sh      # Comprehensive test suite
│   ├── validate-deployment.sh    # End-to-end validation
│   └── README.md                 # Scripts documentation
├── run-project.sh                # Execution guide
├── README.md                     # This file
└── LICENSE                       # Project license
```

---

