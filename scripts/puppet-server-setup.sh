#!/bin/bash

# Puppet Server Setup Script
# Run this on the EC2 instance designated as Puppet Server

set -e

echo "🔴 Starting Puppet Server Setup..."

# Update system
echo "📦 Updating system packages..."
sudo apt update

# Download and install Puppet repository
echo "📥 Adding Puppet repository..."
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update

# Install Puppet Server
echo "🔧 Installing Puppet Server..."
sudo apt install -y puppetserver

# Configure memory settings
echo "⚙️ Configuring memory settings..."
sudo sed -i 's/JAVA_ARGS="-Xms2g -Xmx2g"/JAVA_ARGS="-Xms512m -Xmx512m"/' /etc/default/puppetserver

# Create production environment structure
echo "📂 Creating environment structure..."
sudo mkdir -p /etc/puppetlabs/code/environments/production/manifests

# Create site.pp manifest
echo "📝 Creating site.pp manifest..."
sudo tee /etc/puppetlabs/code/environments/production/manifests/site.pp > /dev/null << 'EOF'
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
    content => "Apache managed by Puppet Server - $(date)\n",
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    require => Package['apache2'],
  }

}

# Default node configuration
node default {
  notify { 'Default node': 
    message => "No specific configuration for this node"
  }
}
EOF

# Set hostname
echo "🏷️ Setting hostname..."
sudo hostnamectl set-hostname puppetserver

# Start and enable Puppet Server
echo "🚀 Starting Puppet Server..."
sudo systemctl start puppetserver
sudo systemctl enable puppetserver

# Wait for service to be ready
echo "⏳ Waiting for Puppet Server to be ready..."
sleep 30

# Check status
echo "✅ Checking Puppet Server status..."
sudo systemctl status puppetserver --no-pager

echo "🎉 Puppet Server setup complete!"
echo "📋 Next steps:"
echo "   1. Set up Puppet Agent on the second EC2 instance"
echo "   2. Sign certificates when agent requests them"
echo "   3. Test the configuration"

# Display useful commands
echo ""
echo "🔑 Useful commands for certificate management:"
echo "   - List pending certificates: sudo /opt/puppetlabs/bin/puppetserver ca list"
echo "   - Sign all certificates: sudo /opt/puppetlabs/bin/puppetserver ca sign --all"
echo "   - List signed certificates: sudo /opt/puppetlabs/bin/puppetserver ca list --all"