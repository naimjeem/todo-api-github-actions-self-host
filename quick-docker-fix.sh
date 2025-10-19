#!/bin/bash

# Quick Docker Permission Fix
echo "🔧 Quick Docker Permission Fix"
echo "=============================="

echo "Current user: $(whoami)"
echo "Current groups: $(groups)"

echo ""
echo "🔧 Adding user to docker group..."
if sudo usermod -aG docker $USER; then
    echo "✅ User added to docker group"
else
    echo "❌ Failed to add user to docker group"
    exit 1
fi

echo ""
echo "🔧 Starting Docker daemon..."
if sudo systemctl start docker; then
    echo "✅ Docker daemon started"
else
    echo "❌ Failed to start Docker daemon"
fi

echo ""
echo "🔧 Enabling Docker auto-start..."
if sudo systemctl enable docker; then
    echo "✅ Docker auto-start enabled"
else
    echo "❌ Failed to enable Docker auto-start"
fi

echo ""
echo "🎯 IMPORTANT: You need to apply the group changes!"
echo "Run one of these commands:"
echo "1. newgrp docker"
echo "2. Or logout and login again"
echo "3. Or restart your terminal session"
echo ""
echo "Then test with: docker info"
