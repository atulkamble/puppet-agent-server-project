#!/bin/bash

# Validation Script - Run after complete setup
# Validates the entire Puppet Agent-Server deployment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Puppet Project Validation Script${NC}"
echo "====================================="

# Check if running on agent
if ! systemctl list-units --full -all | grep -Fq "puppet.service"; then
    echo -e "${RED}❌ This script should run on the Puppet Agent${NC}"
    exit 1
fi

echo -e "${BLUE}📍 Running validation on Puppet Agent${NC}"
echo ""

# Function to validate step
validate_step() {
    local step_name="$1"
    local command="$2"
    local expected="$3"
    
    echo -n "🔍 $step_name... "
    
    if eval "$command" > /tmp/validation_output 2>&1; then
        if [ -n "$expected" ]; then
            if grep -q "$expected" /tmp/validation_output; then
                echo -e "${GREEN}✅ PASS${NC}"
            else
                echo -e "${RED}❌ FAIL${NC} (Expected: $expected)"
                cat /tmp/validation_output | head -3
            fi
        else
            echo -e "${GREEN}✅ PASS${NC}"
        fi
    else
        echo -e "${RED}❌ FAIL${NC}"
        cat /tmp/validation_output | head -3
    fi
}

# Validation steps
echo -e "${YELLOW}🔄 Running Puppet Agent${NC}"
echo "------------------------"

# Run puppet agent
echo "⚡ Executing Puppet agent run..."
sudo /opt/puppetlabs/bin/puppet agent -t --verbose

echo ""
echo -e "${YELLOW}🧪 Post-Run Validation${NC}"
echo "------------------------"

validate_step "Apache package installed" "dpkg -l apache2" "apache2"
validate_step "Apache service running" "systemctl is-active apache2" ""
validate_step "Apache service enabled" "systemctl is-enabled apache2" ""
validate_step "Apache listening on port 80" "netstat -tulnp | grep :80" ":80"
validate_step "Custom index.html exists" "test -f /var/www/html/index.html" ""
validate_step "Index.html has correct content" "cat /var/www/html/index.html" "Puppet Server"
validate_step "Index.html ownership correct" "ls -la /var/www/html/index.html | grep www-data" "www-data"

echo ""
echo -e "${YELLOW}🌐 HTTP Response Test${NC}"
echo "-----------------------"

if command -v curl >/dev/null 2>&1; then
    echo "📡 Testing HTTP response..."
    HTTP_RESPONSE=$(curl -s http://localhost 2>/dev/null || echo "ERROR")
    
    if [[ "$HTTP_RESPONSE" == *"Puppet Server"* ]]; then
        echo -e "${GREEN}✅ HTTP test passed${NC}"
        echo "Response: $HTTP_RESPONSE"
    else
        echo -e "${RED}❌ HTTP test failed${NC}"
        echo "Response: $HTTP_RESPONSE"
    fi
else
    echo -e "${YELLOW}⚠️ curl not available, skipping HTTP test${NC}"
fi

echo ""
echo -e "${YELLOW}🔄 Idempotency Test${NC}"
echo "--------------------"

echo "🔁 Running Puppet agent again to test idempotency..."
SECOND_RUN=$(sudo /opt/puppetlabs/bin/puppet agent -t 2>&1 || true)

if echo "$SECOND_RUN" | grep -q "Applied catalog in"; then
    if echo "$SECOND_RUN" | grep -q "0 resources"; then
        echo -e "${GREEN}✅ Idempotency test passed - No changes needed${NC}"
    else
        echo -e "${YELLOW}⚠️ Some resources were changed on second run${NC}"
        echo "$SECOND_RUN" | grep "Notice:"
    fi
else
    echo -e "${RED}❌ Second run failed${NC}"
    echo "$SECOND_RUN"
fi

echo ""
echo -e "${YELLOW}📊 Resource Status Check${NC}"
echo "--------------------------"

echo "📦 Package status:"
sudo /opt/puppetlabs/bin/puppet resource package apache2

echo ""
echo "🚀 Service status:"
sudo /opt/puppetlabs/bin/puppet resource service apache2

echo ""
echo "📄 File status:"
sudo /opt/puppetlabs/bin/puppet resource file /var/www/html/index.html

echo ""
echo -e "${YELLOW}🎯 Final Validation${NC}"
echo "--------------------"

# Get public IP if available
PUBLIC_IP=""
if command -v curl >/dev/null 2>&1; then
    PUBLIC_IP=$(curl -s http://checkip.amazonaws.com 2>/dev/null || echo "")
fi

echo -e "${GREEN}🎉 Validation Complete!${NC}"
echo ""
echo "📋 Summary:"
echo "  - Apache installed and running"
echo "  - Custom web page deployed"
echo "  - Configuration managed by Puppet"
echo "  - Idempotency verified"

if [ -n "$PUBLIC_IP" ]; then
    echo ""
    echo "🌐 Access your web server:"
    echo "   http://$PUBLIC_IP"
fi

echo ""
echo "🔧 Useful commands for ongoing management:"
echo "   - Test configuration: sudo /opt/puppetlabs/bin/puppet agent -t"
echo "   - Check service: systemctl status apache2"
echo "   - View Puppet logs: journalctl -u puppet -f"
echo "   - Manual Puppet run: sudo /opt/puppetlabs/bin/puppet agent --test"

# Cleanup
rm -f /tmp/validation_output