#!/bin/bash

# Project Execution Guide
# This script provides step-by-step guidance to run the Puppet project

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🐘 Puppet Agent-Server Project Execution Guide${NC}"
echo "=================================================="
echo ""

echo -e "${YELLOW}📋 Instance Configuration${NC}"
echo "----------------------------"
echo "✅ Instance Type: t3.medium"
echo "✅ Key Pair: puppet.pem"
echo "✅ Security Group Ports: 8140, 22, 80"
echo ""
echo "🖥️ Server Instance (i-0d58a7d3956e6d4f9):"
echo "   Public IP: 34.230.29.197"
echo "   Private IP: 172.31.24.198"
echo ""
echo "🖥️ Agent Instance (i-0d4b78d801167ee2f):"
echo "   Public IP: 98.94.87.179"
echo "   Private IP: 172.31.17.211"
echo ""

echo -e "${YELLOW}🚀 Execution Steps${NC}"
echo "-------------------"

echo -e "${BLUE}Step 1: Setup Puppet Server${NC}"
echo "  1. SSH into server instance (34.230.29.197):"
echo "     ${CYAN}ssh -i puppet.pem ubuntu@34.230.29.197${NC}"
echo "  2. Upload and run: ./scripts/puppet-server-setup.sh"
echo "  3. Wait for installation to complete"
echo ""

echo -e "${BLUE}Step 2: Setup Puppet Agent${NC}"
echo "  1. SSH into agent instance (98.94.87.179):"
echo "     ${CYAN}ssh -i puppet.pem ubuntu@98.94.87.179${NC}"
echo "  2. Upload and run: ./scripts/puppet-agent-setup.sh 172.31.24.198"
echo "     (Using server's private IP: 172.31.24.198)"
echo ""

echo -e "${BLUE}Step 3: Certificate Management${NC}"
echo "  1. On Puppet Server, list pending certificates:"
echo "     ${CYAN}sudo /opt/puppetlabs/bin/puppetserver ca list${NC}"
echo "  2. Sign the agent certificate:"
echo "     ${CYAN}sudo /opt/puppetlabs/bin/puppetserver ca sign --all${NC}"
echo "  3. On Puppet Agent, run:"
echo "     ${CYAN}sudo /opt/puppetlabs/bin/puppet agent -t${NC}"
echo ""

echo -e "${BLUE}Step 4: Validation${NC}"
echo "  1. On Puppet Agent, run validation script:"
echo "     ${CYAN}./scripts/validate-deployment.sh${NC}"
echo "  2. Test web server in browser:"
echo "     ${CYAN}http://<AGENT_PUBLIC_IP>${NC}"
echo ""

echo -e "${YELLOW}🧪 Testing Commands${NC}"
echo "--------------------"
echo "• Run tests on either instance: ${CYAN}./scripts/test-puppet-setup.sh${NC}"
echo "• Manual Puppet run: ${CYAN}sudo /opt/puppetlabs/bin/puppet agent -t${NC}"
echo "• Check service status: ${CYAN}systemctl status apache2${NC}"
echo "• View Puppet logs: ${CYAN}journalctl -u puppet -f${NC}"
echo ""

echo -e "${YELLOW}🔧 Troubleshooting${NC}"
echo "-------------------"
echo "• Certificate issues: Check hostname resolution in /etc/hosts"
echo "• Connection refused: Verify Security Group rules for port 8140"
echo "• Agent not updating: Check Puppet Server logs: ${CYAN}journalctl -u puppetserver${NC}"
echo "• Apache not starting: Check manifest syntax in site.pp"
echo ""

echo -e "${GREEN}🎯 Expected Results${NC}"
echo "--------------------"
echo "✅ Apache web server running on agent"
echo "✅ Custom web page: 'Apache managed by Puppet Server'"
echo "✅ Automated configuration management"
echo "✅ Idempotent deployments"
echo ""

echo -e "${YELLOW}⚡ Quick Start Commands${NC}"
echo "------------------------"
echo ""
echo -e "${CYAN}# Make scripts executable:${NC}"
echo "chmod +x scripts/*.sh"
echo ""
echo -e "${CYAN}# On Puppet Server (replace with your server IP):${NC}"
echo "./scripts/puppet-server-setup.sh"
echo ""
echo -e "${CYAN}# On Puppet Agent (replace with your server's private IP):${NC}"
echo "./scripts/puppet-agent-setup.sh 10.0.1.100"
echo ""
echo -e "${CYAN}# Run tests:${NC}"
echo "./scripts/test-puppet-setup.sh"
echo ""
echo -e "${CYAN}# Validate deployment:${NC}"
echo "./scripts/validate-deployment.sh"
echo ""

echo -e "${GREEN}🎉 Ready to run your Puppet project!${NC}"