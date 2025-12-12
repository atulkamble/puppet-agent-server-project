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

