#!/bin/bash

# Script to enable GitHub Advanced Security features

echo "Enabling GitHub Advanced Security features"
echo "=========================================="
echo ""

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set."
    echo "Please run the setup script first:"
    echo "  /home/johnycash/ai-tools/githubupdater/setup_comprehensive_environment.sh"
    exit 1
fi

# List all repositories
echo "Fetching list of repositories..."
repos=$(gh repo list --limit 1000 | awk '{print $1}')

# Function to enable Advanced Security for a repository
enable_advanced_security() {
    local repo=$1
    echo "Enabling Advanced Security for: $repo"
    
    # Extract owner and repo name
    owner=$(echo "$repo" | cut -d'/' -f1)
    repo_name=$(echo "$repo" | cut -d'/' -f2)
    
    # Enable Advanced Security using the GitHub API
    response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/$repo \
        -X PATCH \
        -d '{
            "security_and_analysis": {
                "advanced_security": {
                    "status": "enabled"
                },
                "secret_scanning": {
                    "status": "enabled"
                },
                "secret_scanning_push_protection": {
                    "status": "enabled"
                }
            }
        }')
    
    # Check if Advanced Security was enabled successfully
    if echo "$response" | jq -e '.security_and_analysis' > /dev/null 2>&1; then
        echo "✅ Advanced Security enabled successfully for $repo"
        
        # Display current security settings
        advanced_security_status=$(echo "$response" | jq -r '.security_and_analysis.advanced_security.status')
        secret_scanning_status=$(echo "$response" | jq -r '.security_and_analysis.secret_scanning.status')
        secret_scanning_push_protection_status=$(echo "$response" | jq -r '.security_and_analysis.secret_scanning_push_protection.status')
        
        echo "   Advanced Security: $advanced_security_status"
        echo "   Secret Scanning: $secret_scanning_status"
        echo "   Secret Scanning Push Protection: $secret_scanning_push_protection_status"
    else
        error_message=$(echo "$response" | jq -r '.message')
        echo "❌ Failed to enable Advanced Security for $repo. Error: $error_message"
    fi
    
    echo ""
}

# Process each repository
for repo in $repos; do
    enable_advanced_security "$repo"
done

echo "GitHub Advanced Security setup completed."