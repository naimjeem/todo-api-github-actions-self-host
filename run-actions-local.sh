#!/bin/bash

# Quick GitHub Actions Local Runner
# This script helps you run your GitHub Actions pipeline locally

set -e

echo "🚀 GitHub Actions Local Runner"
echo "=============================="

# Check if act is installed
if command -v act &> /dev/null; then
    echo "✅ act is installed"
    echo "Running with act..."
    
    # List available workflows
    echo "Available workflows:"
    act -l
    
    echo ""
    echo "Choose an option:"
    echo "1. Run all workflows"
    echo "2. Run test job only"
    echo "3. Run build job only"
    echo "4. Run with specific event"
    
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            echo "Running all workflows..."
            act
            ;;
        2)
            echo "Running test job..."
            act -j test
            ;;
        3)
            echo "Running build job..."
            act -j build-and-push
            ;;
        4)
            echo "Available events: push, pull_request, workflow_dispatch"
            read -p "Enter event: " event
            act $event
            ;;
        *)
            echo "Invalid choice. Running all workflows..."
            act
            ;;
    esac
    
else
    echo "❌ act is not installed"
    echo ""
    echo "Installing act..."
    
    # Try to install act
    if curl -fsSL https://raw.githubusercontent.com/nektos/act/master/install.sh | bash; then
        echo "✅ act installed successfully"
        echo "Please run this script again to use act"
    else
        echo "❌ Failed to install act"
        echo ""
        echo "Alternative: Running pipeline manually with Docker..."
        
        # Fallback to manual Docker simulation
        echo "🧪 Running Test Job Simulation..."
        
        # Start PostgreSQL
        docker run -d --name test-postgres \
            -e POSTGRES_PASSWORD=postgres \
            -e POSTGRES_DB=test_todoapp \
            -p 5432:5432 \
            postgres:15
        
        # Wait for PostgreSQL
        echo "Waiting for PostgreSQL..."
        sleep 10
        
        # Run tests
        echo "Running tests..."
        docker run --rm \
            --network host \
            -v $(pwd):/workspace \
            -w /workspace \
            -e NODE_ENV=test \
            -e DB_HOST=localhost \
            -e DB_PORT=5432 \
            -e DB_NAME=test_todoapp \
            -e DB_USER=postgres \
            -e DB_PASSWORD=postgres \
            -e JWT_SECRET=test-secret-key \
            node:18-alpine sh -c "
                npm ci &&
                npm run lint &&
                npm test
            "
        
        # Cleanup
        docker stop test-postgres
        docker rm test-postgres
        
        echo "✅ Manual pipeline simulation completed!"
    fi
fi

echo ""
echo "📚 For more options, see RUN-GITHUB-ACTIONS-LOCALLY.md"
