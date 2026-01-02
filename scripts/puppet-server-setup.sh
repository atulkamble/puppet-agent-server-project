#!/bin/bash

# Puppet Server Setup Script for Ubuntu
# Run this on the EC2 instance designated as Puppet Server
# Instance: i-0d58a7d3956e6d4f9 (34.230.29.197 / 172.31.24.198)

set -e

echo "🔴 Starting Puppet Server Setup..."

# Update system
echo "📦 Updating system packages..."
sudo apt update -y

# Install wget
echo "📥 Installing wget..."
sudo apt install -y wget

# Download and install Puppet 7 repository
echo "📥 Adding Puppet 7 repository..."
wget https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update

# Install Puppet Server
echo "🔧 Installing Puppet Server..."
sudo apt install -y puppetserver

# Clean up any existing installations first
echo "🧹 Cleaning up any previous installations..."
sudo apt remove --purge -y puppetserver puppet-agent puppet7-release puppet-module-puppetlabs-mailalias-core 2>/dev/null || true
sudo apt autoremove -y
sudo apt clean
sudo rm -f /etc/apt/sources.list.d/puppet*.list
sudo rm -f /etc/apt/trusted.gpg.d/puppet*.gpg

# Re-install after cleanup
echo "📥 Re-adding Puppet 7 repository after cleanup..."
wget -O puppet7-release-focal.deb https://apt.puppet.com/puppet7-release-focal.deb
sudo dpkg -i puppet7-release-focal.deb
sudo apt update

echo "🔧 Re-installing Puppet Server..."
sudo apt install -y puppetserver

# Add Puppet to PATH
echo "🛤️ Adding Puppet to PATH..."
echo 'export PATH=/opt/puppetlabs/bin:$PATH' >> ~/.bashrc
export PATH=/opt/puppetlabs/bin:$PATH

# Verify installation
echo "✅ Verifying installation..."
puppetserver --version
puppet --version

# Configure memory settings for t3.medium
echo "⚙️ Configuring memory settings for t3.medium..."
sudo sed -i 's/JAVA_ARGS="-Xms2g -Xmx2g"/JAVA_ARGS="-Xms1g -Xmx1g"/' /etc/default/puppetserver

# Create puppet-apache directory structure
echo "📂 Creating puppet-apache directory structure..."
mkdir -p puppet-apache/{manifests,files}
cd puppet-apache/manifests

# Create site.pp manifest
echo "📝 Creating site.pp manifest..."
cat > site.pp << 'EOF'
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
EOF

# Also create in the standard Puppet location
echo "📝 Creating production environment manifest..."
sudo mkdir -p /etc/puppetlabs/code/environments/production/manifests
sudo cp site.pp /etc/puppetlabs/code/environments/production/manifests/

# Set hostname
echo "🏷️ Setting hostname..."
sudo hostnamectl set-hostname puppetserver

# Start and enable Puppet Server
echo "🚀 Starting Puppet Server..."
sudo systemctl start puppet
sudo systemctl enable puppet
sudo systemctl start puppetserver
sudo systemctl enable puppetserver

# Check status
echo "✅ Checking Puppet Server status..."
sudo systemctl status puppet --no-pager
sudo systemctl status puppetserver --no-pager

echo "🎉 Puppet Server setup complete!"
echo "📋 Instance Details:"
echo "   Instance ID: i-0d58a7d3956e6d4f9"
echo "   Public IP: 34.230.29.197"
echo "   Private IP: 172.31.24.198"
echo ""
echo "📋 Next steps:"
echo "   1. Set up Puppet Agent on instance i-0d4b78d801167ee2f"
echo "   2. Sign certificates when agent requests them"
echo "   3. Test the configuration"
echo ""
echo "🔑 Useful commands for certificate management:"
echo "   - List pending certificates: sudo /opt/puppetlabs/bin/puppetserver ca list"
echo "   - Sign all certificates: sudo /opt/puppetlabs/bin/puppetserver ca sign --all"
echo "   - List signed certificates: sudo /opt/puppetlabs/bin/puppetserver ca list --all"