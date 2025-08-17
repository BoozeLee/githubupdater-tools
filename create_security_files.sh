#!/bin/bash

# Script to create SECURITY.md files in all repositories

echo "Creating SECURITY.md files in all repositories"
echo "=============================================="
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

# Function to create SECURITY.md in a repository
create_security_file() {
    local repo=$1
    echo "Creating SECURITY.md in: $repo"
    
    # Create a temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Clone the repository
    echo "Cloning repository..."
    git clone "https://BoozeLee444:$GITHUB_TOKEN@github.com/$repo.git" .
    
    # Check if SECURITY.md already exists
    if [ -f "SECURITY.md" ]; then
        echo "SECURITY.md already exists in $repo, skipping..."
        cd ..
        rm -rf "$temp_dir"
        return 0
    fi
    
    # Create SECURITY.md content
    cat > SECURITY.md << 'EOF'
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
    
    # Add SECURITY.md to the repository
    git add SECURITY.md
    
    # Configure git user information
    git config --global user.email "kiliaanv2@gmail.com"
    git config --global user.name "BoozeLee444"
    
    # Make a commit
    git commit -m "Add SECURITY.md with security policy"
    
    # Push the commit
    echo "Pushing SECURITY.md to $repo..."
    git push
    
    # Clean up
    cd ..
    rm -rf "$temp_dir"
    
    echo "SECURITY.md created and pushed to $repo"
    echo ""
}

# Process each repository
for repo in $repos; do
    create_security_file "$repo"
done

echo "SECURITY.md files created in all repositories."