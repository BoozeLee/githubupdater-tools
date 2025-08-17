#!/bin/bash

# Script to verify the state of repositories and create pull requests if needed

echo "Verifying Repository States and Creating Pull Requests"
echo "======================================================"
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

# Function to check repository state and create PR if needed
check_and_create_pr() {
    local repo=$1
    echo "Checking repository: $repo"
    
    # Create a temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Clone the repository
    echo "Cloning repository..."
    git clone "https://BoozeLee444:$GITHUB_TOKEN@github.com/$repo.git" .
    
    # Check for SECURITY.md
    if [ -f "SECURITY.md" ]; then
        echo "✅ SECURITY.md exists in $repo"
    else
        echo "❌ SECURITY.md missing in $repo"
    fi
    
    # Check for CI workflow
    if [ -f ".github/workflows/ci.yml" ]; then
        echo "✅ CI workflow exists in $repo"
    else
        echo "❌ CI workflow missing in $repo"
    fi
    
    # Check if there are any uncommitted changes
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "⚠️  There are uncommitted changes in $repo"
        
        # Get the default branch
        default_branch=$(git remote show origin | grep "HEAD branch" | cut -d' ' -f5)
        
        # Create a new branch for the changes
        feature_branch="automated-changes-$(date +%s)"
        git checkout -b "$feature_branch"
        
        # Configure git user information
        git config --global user.email "kiliaanv2@gmail.com"
        git config --global user.name "BoozeLee444"
        
        # Commit the changes
        git add .
        git commit -m "Automated changes: Security and CI/CD setup"
        
        # Push the new branch
        echo "Pushing feature branch to $repo..."
        git push origin "$feature_branch"
        
        # Create a pull request using the GitHub API
        echo "Creating pull request for $repo..."
        response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/repos/$repo/pulls \
            -d "{
                \"title\": \"Automated Security and CI/CD Setup\",
                \"head\": \"$feature_branch\",
                \"base\": \"$default_branch\",
                \"body\": \"This pull request includes automated changes for:\\n- Security policy (SECURITY.md)\\n- CI/CD workflow setup (.github/workflows/ci.yml)\"
            }")
        
        # Check if the pull request was created successfully
        if echo "$response" | jq -e '.number' > /dev/null 2>&1; then
            pr_number=$(echo "$response" | jq -r '.number')
            echo "✅ Pull request created successfully for $repo: #$pr_number"
            echo "   URL: https://github.com/$repo/pull/$pr_number"
        else
            error_message=$(echo "$response" | jq -r '.message')
            echo "❌ Failed to create pull request for $repo. Error: $error_message"
        fi
    else
        echo "ℹ️  No pending changes in $repo"
    fi
    
    # Clean up
    cd ..
    rm -rf "$temp_dir"
    
    echo ""
}

# List of repositories that had push failures
repos_with_failures=(
    "BoozeLee/voidshatterecho"
    "BoozeLee/sentiment-analysis-bert"
    "BoozeLee/symmetrical-waffle"
    "BoozeLee/githubupdater-tools"
)

# Process each repository with push failures
for repo in "${repos_with_failures[@]}"; do
    check_and_create_pr "$repo"
done

echo "Repository verification and pull request creation process completed."