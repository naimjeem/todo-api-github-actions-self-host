#!/bin/bash

# Fix Docker Permission Issues Script
# This script helps resolve Docker permission problems

echo "🔧 Fixing Docker Permission Issues"
echo "================================="

# Check current user
echo "Current user: $(whoami)"
echo "User groups: $(groups)"

# Check if user is in docker group
if groups | grep -q docker; then
    echo "✅ User is already in docker group"
else
    echo "❌ User is NOT in docker group"
    echo ""
    echo "To fix this, run the following commands:"
    echo "sudo usermod -aG docker $USER"
    echo "newgrp docker"
    echo ""
    echo "Or logout and login again after running the usermod command"
fi

echo ""

# Check Docker socket permissions
echo "Checking Docker socket permissions..."
if [ -S /var/run/docker.sock ]; then
    echo "Docker socket exists"
    ls -la /var/run/docker.sock
else
    echo "❌ Docker socket not found"
fi

echo ""

# Try to start Docker daemon
echo "Attempting to start Docker daemon..."
if sudo systemctl start docker; then
    echo "✅ Docker daemon started successfully"
else
    echo "❌ Failed to start Docker daemon"
fi

echo ""

# Test Docker access
echo "Testing Docker access..."
if docker info >/dev/null 2>&1; then
    echo "✅ Docker is accessible"
    docker --version
else
    echo "❌ Docker is not accessible"
    echo ""
    echo "Possible solutions:"
    echo "1. Add user to docker group: sudo usermod -aG docker $USER"
    echo "2. Start new shell session: newgrp docker"
    echo "3. Logout and login again"
    echo "4. Start Docker daemon: sudo systemctl start docker"
fi

echo ""
echo "🎯 Next Steps:"
echo "============="
echo "1. Run: sudo usermod -aG docker $USER"
echo "2. Run: newgrp docker"
echo "3. Test: docker info"
echo "4. Restart your GitHub Actions runner"
