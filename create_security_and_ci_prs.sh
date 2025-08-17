#!/bin/bash

# Script to create SECURITY.md and CI workflows via pull requests for all repositories

echo "Creating SECURITY.md and CI Workflows via Pull Requests"
echo "======================================================="
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

# List all repositories
echo "Fetching list of repositories..."
repos=$(gh repo list --limit 1000 | awk '{print $1}')

# Function to create SECURITY.md content
create_security_content() {
    cat << 'EOF'
# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please send an email to kiliaanv2@gmail.com. All security vulnerabilities will be promptly addressed.

Please do not publicly disclose the issue until it has been addressed by the team.

## Security Measures

We take security seriously and have implemented the following measures:

1. All dependencies are regularly updated to address known vulnerabilities
2. Code is reviewed before merging to the main branch
3. Branch protection rules are enabled to prevent force pushes
4. Automated security scanning is integrated into our CI/CD pipeline

## Contact

For any security-related questions or concerns, please contact:
- Email: kiliaanv2@gmail.com
- GitHub: [@BoozeLee](https://github.com/BoozeLee)

We appreciate your efforts to keep our project secure.
EOF
}

# Function to create Python CI workflow
create_python_ci_workflow() {
    cat << 'EOF'
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, "3.10", "3.11"]

    steps:
    - uses: actions/checkout@v3
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest
    - name: Test with pytest
      run: |
        pytest
EOF
}

# Function to create Node.js CI workflow
create_nodejs_ci_workflow() {
    cat << 'EOF'
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]

    steps:
    - uses: actions/checkout@v3
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    - run: npm ci
    - run: npm test
EOF
}

# Function to create generic CI workflow
create_generic_ci_workflow() {
    cat << 'EOF'
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - name: Run basic checks
      run: |
        echo "No specific language detected, running generic checks"
        # Add your generic checks here
EOF
}

# Function to create pull request for a repository
create_pr_for_repo() {
    local repo=$1
    echo "Processing repository: $repo"
    
    # Create a temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Clone the repository
    echo "Cloning repository..."
    git clone "https://BoozeLee444:$GITHUB_TOKEN@github.com/$repo.git" .
    
    # Check if SECURITY.md already exists
    if [ ! -f "SECURITY.md" ]; then
        echo "Creating SECURITY.md for $repo..."
        create_security_content > SECURITY.md
    else
        echo "SECURITY.md already exists in $repo"
    fi
    
    # Create .github/workflows directory if it doesn't exist
    mkdir -p .github/workflows
    
    # Check if any workflow already exists
    if [ ! -f ".github/workflows/ci.yml" ]; then
        echo "Creating CI workflow for $repo..."
        # Create a CI workflow based on the repository type
        if [ -f "requirements.txt" ]; then
            # Python project
            create_python_ci_workflow > .github/workflows/ci.yml
            echo "Created Python CI workflow for $repo"
        elif [ -f "package.json" ]; then
            # Node.js project
            create_nodejs_ci_workflow > .github/workflows/ci.yml
            echo "Created Node.js CI workflow for $repo"
        elif [ -f "Gemfile" ]; then
            # Ruby project (using generic workflow for now)
            create_generic_ci_workflow > .github/workflows/ci.yml
            echo "Created generic CI workflow for $repo (Ruby project)"
        else
            # Generic workflow for other project types
            create_generic_ci_workflow > .github/workflows/ci.yml
            echo "Created generic CI workflow for $repo"
        fi
    else
        echo "CI workflow already exists in $repo"
    fi
    
    # Check if there are any changes to commit
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "Creating pull request for $repo..."
        
        # Get the default branch
        default_branch=$(git remote show origin | grep "HEAD branch" | cut -d' ' -f5)
        
        # Create a new branch for the changes
        feature_branch="security-and-ci-setup-$(date +%s)"
        git checkout -b "$feature_branch"
        
        # Configure git user information
        git config --global user.email "kiliaanv2@gmail.com"
        git config --global user.name "BoozeLee444"
        
        # Commit the changes
        git add .
        git commit -m "Add security policy and CI workflow"
        
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
                \"title\": \"Add Security Policy and CI Workflow\",
                \"head\": \"$feature_branch\",
                \"base\": \"$default_branch\",
                \"body\": \"This pull request adds:\\n- Security policy (SECURITY.md)\\n- CI workflow (.github/workflows/ci.yml)\\n\\nThese changes were automatically generated to improve the security and maintainability of the repository.\"
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
        echo "No changes to commit for $repo"
    fi
    
    # Clean up
    cd ..
    rm -rf "$temp_dir"
    
    echo ""
}

# Process each repository
for repo in $repos; do
    create_pr_for_repo "$repo"
done

echo "Pull request creation process completed for all repositories."
echo ""
echo "Next steps:"
echo "1. Review the created pull requests on GitHub"
echo "2. Merge them after review"
echo "3. Delete the feature branches after merging"