#!/bin/bash

# Comprehensive Docker Fix Script
# This script fixes all Docker permission and daemon issues

echo "🔧 Comprehensive Docker Fix"
echo "=========================="

# Check current user
echo "Current user: $(whoami)"
echo "User groups: $(groups)"

# Check if user is in docker group
if groups | grep -q docker; then
    echo "✅ User is already in docker group"
else
    echo "❌ User is NOT in docker group"
    echo ""
    echo "🔧 Fixing Docker group membership..."
    
    # Add user to docker group
    if sudo usermod -aG docker $USER; then
        echo "✅ User added to docker group"
    else
        echo "❌ Failed to add user to docker group"
        exit 1
    fi
fi

echo ""

# Check Docker daemon status
echo "🔧 Checking Docker daemon status..."
if systemctl is-active --quiet docker; then
    echo "✅ Docker daemon is running"
else
    echo "❌ Docker daemon is not running"
    echo "🔧 Starting Docker daemon..."
    
    if sudo systemctl start docker; then
        echo "✅ Docker daemon started"
    else
        echo "❌ Failed to start Docker daemon"
        exit 1
    fi
fi

# Enable Docker to start automatically
echo "🔧 Enabling Docker auto-start..."
if sudo systemctl enable docker; then
    echo "✅ Docker auto-start enabled"
else
    echo "❌ Failed to enable Docker auto-start"
fi

echo ""

# Apply group changes
echo "🔧 Applying group changes..."
if newgrp docker; then
    echo "✅ Group changes applied"
else
    echo "❌ Failed to apply group changes"
    echo "You may need to logout and login again"
fi

echo ""

# Test Docker access
echo "🧪 Testing Docker access..."
if docker info >/dev/null 2>&1; then
    echo "✅ Docker is accessible"
    echo ""
    echo "Docker version:"
    docker --version
    echo ""
    echo "Docker info:"
    docker info | head -10
else
    echo "❌ Docker is still not accessible"
    echo ""
    echo "🔧 Additional troubleshooting steps:"
    echo "1. Logout and login again"
    echo "2. Or run: newgrp docker"
    echo "3. Or restart your terminal session"
    echo "4. Check: ls -la /var/run/docker.sock"
fi

echo ""
echo "🎯 Next Steps:"
echo "============="
echo "1. If Docker is working, restart your GitHub Actions runner:"
echo "   pkill -f Runner.Listener"
echo "   cd actions-runner && ./run.sh"
echo ""
echo "2. Test the pipeline by pushing a change to your repository"
echo ""
echo "3. Check GitHub Actions tab for pipeline execution"
