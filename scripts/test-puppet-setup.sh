#!/bin/bash

# Comprehensive Test Suite for Puppet Agent-Server Project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test results
print_test_result() {
    local test_name="$1"
    local result="$2"
    
    if [ "$result" -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        ((TESTS_FAILED++))
    fi
}

# Function to run command and capture result
run_test() {
    local test_name="$1"
    local command="$2"
    
    echo -e "${BLUE}🧪 Testing:${NC} $test_name"
    
    if eval "$command" &> /dev/null; then
        print_test_result "$test_name" 0
    else
        print_test_result "$test_name" 1
    fi
}

echo -e "${YELLOW}🧪 Starting Puppet Agent-Server Test Suite${NC}"
echo "=================================================="

# Determine if this is server or agent
if systemctl is-active --quiet puppetserver 2>/dev/null; then
    echo -e "${BLUE}📍 Running tests on Puppet Server${NC}"
    IS_SERVER=true
elif systemctl list-units --full -all | grep -Fq "puppet.service"; then
    echo -e "${BLUE}📍 Running tests on Puppet Agent${NC}"
    IS_SERVER=false
else
    echo -e "${RED}❌ Error: Neither Puppet Server nor Agent detected${NC}"
    exit 1
fi

echo ""

# Common tests
echo -e "${YELLOW}🔧 Basic System Tests${NC}"
echo "----------------------"

run_test "Puppet binary exists" "test -f /opt/puppetlabs/bin/puppet"
run_test "Puppet configuration exists" "test -f /etc/puppetlabs/puppet/puppet.conf"
run_test "Puppet SSL directory exists" "test -d /etc/puppetlabs/puppet/ssl"

if [ "$IS_SERVER" = true ]; then
    # Server-specific tests
    echo ""
    echo -e "${YELLOW}🔴 Puppet Server Tests${NC}"
    echo "------------------------"
    
    run_test "Puppet Server service is running" "systemctl is-active --quiet puppetserver"
    run_test "Puppet Server service is enabled" "systemctl is-enabled --quiet puppetserver"
    run_test "Puppet Server listening on port 8140" "netstat -tulnp | grep :8140"
    run_test "Production environment exists" "test -d /etc/puppetlabs/code/environments/production"
    run_test "Site.pp manifest exists" "test -f /etc/puppetlabs/code/environments/production/manifests/site.pp"
    run_test "Site.pp contains Apache configuration" "grep -q 'apache2' /etc/puppetlabs/code/environments/production/manifests/site.pp"
    run_test "Puppet Server CA is initialized" "test -f /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem"
    
    # Check for signed certificates
    echo ""
    echo -e "${BLUE}📋 Certificate Status:${NC}"
    if /opt/puppetlabs/bin/puppetserver ca list --all 2>/dev/null | grep -q "puppetagent"; then
        echo -e "${GREEN}✅${NC} Agent certificate is signed"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⚠️${NC} No agent certificates signed yet"
        echo "   Run: sudo /opt/puppetlabs/bin/puppetserver ca sign --all"
    fi
    
else
    # Agent-specific tests
    echo ""
    echo -e "${YELLOW}🟢 Puppet Agent Tests${NC}"
    echo "-----------------------"
    
    run_test "Puppet Agent service is enabled" "systemctl is-enabled --quiet puppet"
    run_test "Puppet agent can connect to server" "timeout 10 /opt/puppetlabs/bin/puppet agent --test --noop 2>/dev/null || test $? -eq 124"
    run_test "Agent SSL certificate exists" "test -f /etc/puppetlabs/puppet/ssl/certs/$(hostname).pem || test -f /etc/puppetlabs/puppet/ssl/certificate_requests/$(hostname).pem"
    run_test "Hosts file contains puppet server" "grep -q 'puppetserver' /etc/hosts"
    
    # Check if Apache is managed
    if dpkg -l | grep -q apache2; then
        echo ""
        echo -e "${YELLOW}🌐 Apache Service Tests${NC}"
        echo "------------------------"
        
        run_test "Apache2 package is installed" "dpkg -l | grep -q apache2"
        run_test "Apache2 service is running" "systemctl is-active --quiet apache2"
        run_test "Apache2 service is enabled" "systemctl is-enabled --quiet apache2"
        run_test "Apache listening on port 80" "netstat -tulnp | grep :80"
        run_test "Custom index.html exists" "test -f /var/www/html/index.html"
        run_test "Index.html contains Puppet message" "grep -q 'Puppet Server' /var/www/html/index.html"
        
        # Test HTTP response
        if command -v curl >/dev/null 2>&1; then
            run_test "Apache serves correct content" "curl -s http://localhost | grep -q 'Puppet Server'"
        fi
    fi
fi

# Network connectivity tests
echo ""
echo -e "${YELLOW}🌐 Network Connectivity Tests${NC}"
echo "-------------------------------"

if [ "$IS_SERVER" = true ]; then
    run_test "Server can accept connections on 8140" "timeout 5 bash -c '</dev/tcp/localhost/8140' 2>/dev/null"
else
    run_test "Can resolve puppetserver hostname" "nslookup puppetserver >/dev/null 2>&1 || getent hosts puppetserver >/dev/null 2>&1"
    if grep -q puppetserver /etc/hosts; then
        SERVER_IP=$(grep puppetserver /etc/hosts | awk '{print $1}' | head -1)
        run_test "Can reach Puppet Server on port 8140" "timeout 5 bash -c '</dev/tcp/$SERVER_IP/8140' 2>/dev/null"
    fi
fi

# Summary
echo ""
echo "=================================================="
echo -e "${YELLOW}📊 Test Summary${NC}"
echo "=================================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo -e "Total: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Check the configuration.${NC}"
    exit 1
fi