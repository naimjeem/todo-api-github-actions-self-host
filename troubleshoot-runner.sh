#!/bin/bash

# GitHub Actions Runner Troubleshooting Script
# This script helps diagnose common pipeline failures

echo "🔍 GitHub Actions Runner Troubleshooting"
echo "========================================"

# Check if runner is configured
echo "1. Checking runner configuration..."
if [ -f "actions-runner/.runner" ]; then
    echo "✅ Runner configuration file exists"
    cat actions-runner/.runner
else
    echo "❌ Runner configuration file missing"
fi

echo ""

# Check runner status
echo "2. Checking runner status..."
if pgrep -f "Runner.Listener" > /dev/null; then
    echo "✅ Runner process is running"
    ps aux | grep Runner.Listener | grep -v grep
else
    echo "❌ Runner process is not running"
fi

echo ""

# Check Docker availability
echo "3. Checking Docker availability..."
if command -v docker &> /dev/null; then
    echo "✅ Docker is installed"
    docker --version
    if docker info &> /dev/null; then
        echo "✅ Docker daemon is running"
    else
        echo "❌ Docker daemon is not running"
    fi
else
    echo "❌ Docker is not installed"
fi

echo ""

# Check Docker Compose
echo "4. Checking Docker Compose..."
if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose is installed"
    docker-compose --version
elif docker compose version &> /dev/null; then
    echo "✅ Docker Compose (plugin) is available"
    docker compose version
else
    echo "❌ Docker Compose is not available"
fi

echo ""

# Check Node.js
echo "5. Checking Node.js..."
if command -v node &> /dev/null; then
    echo "✅ Node.js is installed"
    node --version
    npm --version
else
    echo "❌ Node.js is not installed"
fi

echo ""

# Check project files
echo "6. Checking project files..."
if [ -f "package.json" ]; then
    echo "✅ package.json exists"
else
    echo "❌ package.json missing"
fi

if [ -f "Dockerfile" ]; then
    echo "✅ Dockerfile exists"
else
    echo "❌ Dockerfile missing"
fi

if [ -f "docker-compose.yml" ]; then
    echo "✅ docker-compose.yml exists"
else
    echo "❌ docker-compose.yml missing"
fi

echo ""

# Check GitHub connectivity
echo "7. Checking GitHub connectivity..."
if curl -s https://github.com > /dev/null; then
    echo "✅ GitHub is accessible"
else
    echo "❌ Cannot reach GitHub"
fi

echo ""

# Check recent runner logs
echo "8. Checking recent runner logs..."
if [ -d "actions-runner/_diag" ]; then
    echo "Recent log files:"
    ls -la actions-runner/_diag/ | tail -5
    echo ""
    echo "Latest log content:"
    if [ -f "actions-runner/_diag/Runner_$(date +%Y%m%d)*.log" ]; then
        tail -20 actions-runner/_diag/Runner_$(date +%Y%m%d)*.log
    else
        echo "No logs found for today"
    fi
else
    echo "❌ No diagnostic directory found"
fi

echo ""
echo "🎯 Troubleshooting Recommendations:"
echo "=================================="

# Provide recommendations based on checks
if ! pgrep -f "Runner.Listener" > /dev/null; then
    echo "• Start the runner: cd actions-runner && ./run.sh"
fi

if ! docker info &> /dev/null; then
    echo "• Start Docker: sudo systemctl start docker"
fi

if ! command -v node &> /dev/null; then
    echo "• Install Node.js: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
fi

echo "• Check GitHub Actions tab for detailed error messages"
echo "• Ensure Docker Hub credentials are set in GitHub Secrets"
echo "• Verify the workflow file syntax is correct"
