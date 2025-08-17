#!/bin/bash

# Script to load GitHub token and run pull request creation

echo "Loading GitHub Token and Creating Pull Requests"
echo "==============================================="
echo ""

# Function to securely load token
load_token() {
    # Check if GITHUB_TOKEN is already set
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "GITHUB_TOKEN is already set in environment."
        return 0
    fi
    
    # Check for token file
    if [ -f ~/.github_token ]; then
        echo "Loading token from ~/.github_token"
        export GITHUB_TOKEN=$(cat ~/.github_token)
        return 0
    fi
    
    echo "GITHUB_TOKEN is not set in environment or file."
    echo "Please create a ~/.github_token file with your GitHub token."
    exit 1
}

# Load token
load_token

# Verify token works
echo "Verifying token..."
user_response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    https://api.github.com/user)

if echo "$user_response" | jq -e '.login' > /dev/null 2>&1; then
    user=$(echo "$user_response" | jq -r '.login')
    echo "✅ Authenticated as: $user"
else
    echo "❌ Authentication failed. Please check your token."
    exit 1
fi

echo ""
echo "Running pull request creation script..."
/home/johnycash/ai-tools/githubupdater/create_pull_requests.sh