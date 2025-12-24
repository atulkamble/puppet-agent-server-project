#!/bin/bash

# Puppet Agent Setup Script
# Run this on the EC2 instance designated as Puppet Agent
# Usage: ./puppet-agent-setup.sh <PUPPET_SERVER_IP>

set -e

if [ $# -eq 0 ]; then
    echo "❌ Error: Please provide the Puppet Server IP address"
    echo "Usage: $0 <PUPPET_SERVER_IP>"
    exit 1
fi

PUPPET_SERVER_IP=$1

echo "🟢 Starting Puppet Agent Setup..."
echo "🎯 Puppet Server IP: $PUPPET_SERVER_IP"

# Update system
echo "📦 Updating system packages..."
sudo apt update

# Download and install Puppet repository
echo "📥 Adding Puppet repository..."
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update

# Install Puppet Agent
echo "🔧 Installing Puppet Agent..."
sudo apt install -y puppet-agent

# Set hostname
echo "🏷️ Setting hostname..."
sudo hostnamectl set-hostname puppetagent

# Add Puppet Server to hosts file
echo "📝 Configuring hosts file..."
echo "$PUPPET_SERVER_IP puppetserver" | sudo tee -a /etc/hosts

# Configure Puppet Agent
echo "⚙️ Configuring Puppet Agent..."
sudo tee /etc/puppetlabs/puppet/puppet.conf > /dev/null << EOF
[main]
server = puppetserver
environment = production
runinterval = 30m

[agent]
report = true
pluginsync = true
EOF

# Add Puppet to PATH
echo "🛤️ Adding Puppet to PATH..."
echo 'export PATH=$PATH:/opt/puppetlabs/bin' | sudo tee -a /etc/profile
export PATH=$PATH:/opt/puppetlabs/bin

# Enable Puppet Agent service
echo "🚀 Enabling Puppet Agent service..."
sudo systemctl enable puppet

# Test initial connection and certificate request
echo "🔑 Initiating certificate request..."
sudo /opt/puppetlabs/bin/puppet agent -t --verbose || echo "⚠️ Expected: Certificate request sent to server"

echo "🎉 Puppet Agent setup complete!"
echo ""
echo "📋 Next steps:"
echo "   1. On Puppet Server, run: sudo /opt/puppetlabs/bin/puppetserver ca list"
echo "   2. On Puppet Server, run: sudo /opt/puppetlabs/bin/puppetserver ca sign --all"
echo "   3. On this agent, run: sudo /opt/puppetlabs/bin/puppet agent -t"
echo ""
echo "🔧 Useful commands:"
echo "   - Test agent: sudo /opt/puppetlabs/bin/puppet agent -t"
echo "   - Check status: systemctl status puppet"
echo "   - View logs: journalctl -u puppet -f"