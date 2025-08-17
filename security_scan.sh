#!/bin/bash

# Set the GitHub token
export GITHUB_TOKEN=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

# Configure Git to use the token for HTTPS authentication
git config --global credential.helper store
echo "https://BoozeLee444:$GITHUB_TOKEN@github.com" > ~/.git-credentials

# Set Git username and email
git config --global user.email "kiliaanv2@gmail.com"
git config --global user.name "BoozeLee444"

# List all repositories
echo "Fetching list of repositories..."
repos=$(gh repo list --limit 1000 | awk '{print $1}')

# Patterns to search for (sensitive information)
PATTERNS=(
    "password"
    "secret"
    "token"
    "key"
    "api_key"
    "api-key"
    "aws_access_key"
    "aws_secret_key"
    "private_key"
    "client_secret"
    "connection_string"
    "database_url"
    "auth_token"
    "access_token"
    "refresh_token"
    "jwt_secret"
    "encryption_key"
    "ssh_key"
    "credential"
    "passwd"
    "pwd"
    "username.*kiliaanv2"
    "email.*kiliaanv2"
    "personal.*information"
    "ssn"
    "social.*security"
    "credit.*card"
    "bank.*account"
    "routing.*number"
    "driver.*license"
    "passport.*number"
)

# Function to scan a single repository
scan_repo() {
    local repo=$1
    echo "Scanning repository: $repo"
    
    # Create a temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Clone the repository
    echo "Cloning repository..."
    git clone "https://github.com/$repo.git" .
    
    # Search for sensitive patterns
    echo "Searching for sensitive information..."
    for pattern in "${PATTERNS[@]}"; do
        echo "Checking for pattern: $pattern"
        # Search in all files, case-insensitive, show line numbers
        grep -r -i -n "$pattern" . --exclude-dir=.git || echo "No matches found for $pattern"
    done
    
    # Clean up
    cd ..
    rm -rf "$temp_dir"
}

# Process each repository
for repo in $repos; do
    scan_repo "$repo"
done

echo "Security scan completed."