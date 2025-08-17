#!/bin/bash

# Script to create pull requests for changes to protected branches

echo "Creating Pull Requests for Protected Branches"
echo "============================================="
echo ""

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set."
    echo "Please run the setup script first:"
    echo "  /home/johnycash/ai-tools/githubupdater/setup_comprehensive_environment.sh"
    exit 1
fi

# Function to create a pull request for a repository
create_pull_request() {
    local repo=$1
    echo "Checking for pending changes in: $repo"
    
    # Create a temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Clone the repository
    echo "Cloning repository..."
    git clone "https://BoozeLee444:$GITHUB_TOKEN@github.com/$repo.git" .
    
    # Check if there are any uncommitted changes
    if [[ -z "$(git status --porcelain)" ]]; then
        echo "No pending changes in $repo, skipping..."
        cd ..
        rm -rf "$temp_dir"
        return 0
    fi
    
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
    
    # Extract owner and repo name
    owner=$(echo "$repo" | cut -d'/' -f1)
    repo_name=$(echo "$repo" | cut -d'/' -f2)
    
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
    create_pull_request "$repo"
done

echo "Pull request creation process completed."
echo ""
echo "Next steps:"
echo "1. Review the created pull requests on GitHub"
echo "2. Merge them after review"
echo "3. Delete the feature branches after merging"