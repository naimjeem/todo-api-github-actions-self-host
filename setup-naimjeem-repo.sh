#!/bin/bash

# GitHub Repository Setup Script for naimjeem/todo-api-github-actions-self-host
# This script helps set up the repository structure with Dev, UAT, and Main branches

set -e

echo "🚀 Setting up Todo API GitHub Actions Self-Hosted Repository"
echo "Repository: https://github.com/naimjeem/todo-api-github-actions-self-host"
echo "=============================================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository. Initializing..."
    git init
    echo "✅ Git repository initialized"
fi

# Set up remote origin if not already set
if ! git remote get-url origin >/dev/null 2>&1; then
    echo "📡 Setting up remote origin..."
    git remote add origin https://github.com/naimjeem/todo-api-github-actions-self-host.git
    echo "✅ Remote origin set to: https://github.com/naimjeem/todo-api-github-actions-self-host.git"
fi

# Create initial commit if no commits exist
if [ -z "$(git log --oneline 2>/dev/null)" ]; then
    echo "📝 Creating initial commit..."
    git add .
    git commit -m "Initial commit: Todo API with self-hosted GitHub Actions CI/CD pipeline"
    echo "✅ Initial commit created"
fi

# Create and set up branches
echo "🌿 Setting up branch structure..."

# Create dev branch
echo "Creating dev branch..."
git checkout -b dev
git push -u origin dev
echo "✅ Dev branch created and pushed"

# Create uat branch
echo "Creating UAT branch..."
git checkout -b uat
git push -u origin uat
echo "✅ UAT branch created and pushed"

# Switch to main branch
echo "Switching to main branch..."
git checkout main
git push -u origin main
echo "✅ Main branch set up"

# Display branch structure
echo ""
echo "📊 Repository Structure Created:"
echo "================================"
git branch -a
echo ""

# Display Docker Hub configuration
echo "🐳 Docker Hub Configuration:"
echo "============================"
echo "Repository: naimjeem/todo-api-github-actions-self-host"
echo "Images will be tagged as:"
echo "  - naimjeem/todo-api-github-actions-self-host:latest (main branch)"
echo "  - naimjeem/todo-api-github-actions-self-host:dev (dev branch)"
echo "  - naimjeem/todo-api-github-actions-self-host:uat (uat branch)"
echo ""

# Display next steps
echo "🎯 Next Steps:"
echo "=============="
echo "1. Add GitHub Secrets:"
echo "   - Go to: https://github.com/naimjeem/todo-api-github-actions-self-host/settings/secrets/actions"
echo "   - Add DOCKERHUB_USERNAME: Your Docker Hub username"
echo "   - Add DOCKERHUB_TOKEN: Your Docker Hub access token"
echo ""
echo "2. Set up Self-Hosted Runner:"
echo "   - Follow instructions in SELF-HOSTED-RUNNER-SETUP.md"
echo "   - Configure runner with labels: self-hosted, linux, x64"
echo ""
echo "3. Test the CI/CD Pipeline:"
echo "   - Make a change to any file"
echo "   - Commit and push to dev branch: git push origin dev"
echo "   - Check GitHub Actions: https://github.com/naimjeem/todo-api-github-actions-self-host/actions"
echo ""
echo "4. Deploy to Production:"
echo "   - Merge changes to main branch"
echo "   - Pipeline will automatically build and push Docker image"
echo "   - Image will be available at: docker.io/naimjeem/todo-api-github-actions-self-host:latest"
echo ""

# Display repository URLs
echo "🔗 Repository URLs:"
echo "=================="
echo "Repository: https://github.com/naimjeem/todo-api-github-actions-self-host"
echo "Actions: https://github.com/naimjeem/todo-api-github-actions-self-host/actions"
echo "Settings: https://github.com/naimjeem/todo-api-github-actions-self-host/settings"
echo "Secrets: https://github.com/naimjeem/todo-api-github-actions-self-host/settings/secrets/actions"
echo ""

echo "✅ Repository setup complete!"
echo "🔗 Your Todo API is ready for self-hosted CI/CD deployment!"
echo ""
echo "📚 Documentation:"
echo "- README.md: Complete project overview"
echo "- SELF-HOSTED-RUNNER-SETUP.md: Runner setup guide"
echo "- RUN-GITHUB-ACTIONS-LOCALLY.md: Local testing guide"
echo "- DEPLOYMENT.md: Production deployment guide"
