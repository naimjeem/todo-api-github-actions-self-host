#!/bin/bash

# GitHub Repository Setup Script for Todo App CI/CD
# This script helps set up the repository structure with Dev, UAT, and Main branches

set -e

echo "🚀 Setting up Todo App CI/CD Repository Structure"
echo "================================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository. Initializing..."
    git init
    echo "✅ Git repository initialized"
fi

# Create initial commit if no commits exist
if [ -z "$(git log --oneline 2>/dev/null)" ]; then
    echo "📝 Creating initial commit..."
    git add .
    git commit -m "Initial commit: Todo App API with CI/CD pipeline"
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

# Display next steps
echo "🎯 Next Steps:"
echo "=============="
echo "1. Add GitHub Secrets:"
echo "   - Go to repository Settings → Secrets and variables → Actions"
echo "   - Add DOCKERHUB_USERNAME: Your Docker Hub username"
echo "   - Add DOCKERHUB_TOKEN: Your Docker Hub access token"
echo ""
echo "2. Test the CI/CD Pipeline:"
echo "   - Make a change to any file"
echo "   - Commit and push to dev branch: git push origin dev"
echo "   - Check GitHub Actions tab for pipeline execution"
echo ""
echo "3. Deploy to Production:"
echo "   - Merge changes to main branch"
echo "   - Pipeline will automatically build and push Docker image"
echo ""
echo "4. Set up Self-Hosted Runner (Optional):"
echo "   - Follow instructions in DEPLOYMENT.md"
echo "   - Update workflow to use self-hosted runners"
echo ""

echo "✅ Repository setup complete!"
echo "🔗 Your Todo App is ready for CI/CD deployment!"
