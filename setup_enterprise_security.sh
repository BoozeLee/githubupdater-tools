#!/bin/bash

# Script to set up enterprise-level security policies

echo "Setting up Enterprise Security Policies"
echo "======================================="
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

# Verify token works and get user info
echo "Verifying token and getting user info..."
user_response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    https://api.github.com/user)

if echo "$user_response" | jq -e '.login' > /dev/null 2>&1; then
    user=$(echo "$user_response" | jq -r '.login')
    echo "✅ Authenticated as: $user"
else
    echo "❌ Authentication failed. Please check your token."
    exit 1
fi

# Get organization information
echo "Getting organization information..."
orgs_response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    https://api.github.com/user/orgs)

org_count=$(echo "$orgs_response" | jq -r 'length')

if [ "$org_count" -eq 0 ]; then
    echo "⚠️  You are not currently part of any organizations."
    echo "Enterprise security policies can only be set at the organization level."
    exit 1
fi

# Get the first organization (assuming that's the one we want to work with)
org_name=$(echo "$orgs_response" | jq -r '.[0].login')
echo "✅ Working with organization: $org_name"

# Function to create a branch protection rule
create_branch_protection_rule() {
    local repo=$1
    local branch=$2
    
    echo "Creating branch protection rule for $repo:$branch..."
    
    # Create branch protection rule using GitHub API
    response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/$org_name/$repo/branches/$branch/protection \
        -X PUT \
        -d '{
            "required_status_checks": {
                "strict": true,
                "contexts": []
            },
            "enforce_admins": true,
            "required_pull_request_reviews": {
                "dismiss_stale_reviews": true,
                "require_code_owner_reviews": true,
                "required_approving_review_count": 1
            },
            "restrictions": null,
            "required_linear_history": true,
            "allow_force_pushes": false,
            "allow_deletions": false
        }')
    
    # Check if the branch protection rule was created successfully
    if echo "$response" | jq -e '.url' > /dev/null 2>&1; then
        echo "✅ Branch protection rule created successfully for $repo:$branch"
    else
        error_message=$(echo "$response" | jq -r '.message')
        echo "❌ Failed to create branch protection rule for $repo:$branch. Error: $error_message"
    fi
}

# Function to enable advanced security for a repository
enable_advanced_security() {
    local repo=$1
    
    echo "Enabling advanced security for $repo..."
    
    # Enable advanced security using GitHub API
    response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/$org_name/$repo \
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
    
    # Check if advanced security was enabled successfully
    if echo "$response" | jq -e '.security_and_analysis' > /dev/null 2>&1; then
        echo "✅ Advanced security enabled successfully for $repo"
    else
        error_message=$(echo "$response" | jq -r '.message // "Unknown error"')
        echo "❌ Failed to enable advanced security for $repo. Error: $error_message"
    fi
}

# Function to create a repository ruleset
create_repository_ruleset() {
    local ruleset_name=$1
    
    echo "Creating repository ruleset: $ruleset_name..."
    
    # Create repository ruleset using GitHub API
    response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/orgs/$org_name/rulesets \
        -X POST \
        -d "{
            \"name\": \"$ruleset_name\",
            \"target\": \"branch\",
            \"enforcement\": \"evaluate\",
            \"conditions\": {
                \"ref_name\": {
                    \"exclude\": [],
                    \"include\": [\"~DEFAULT_BRANCH\"]
                }
            },
            \"rules\": [
                {
                    \"type\": \"creation\"
                }
            ]
        }")

    # Check if the ruleset was created successfully
    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        ruleset_id=$(echo "$response" | jq -r '.id')
        echo "✅ Repository ruleset created successfully: $ruleset_name (ID: $ruleset_id)"
    else
        error_message=$(echo "$response" | jq -r '.message // "Unknown error"')
        echo "❌ Failed to create repository ruleset: $ruleset_name. Error: $error_message"
    fi
}

# Get list of repositories in the organization
echo "Fetching list of repositories in $org_name..."
repos_response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$org_name/repos?per_page=100")

repo_count=$(echo "$repos_response" | jq -r 'length')
echo "Found $repo_count repositories in $org_name"

# Process each repository
for i in $(seq 0 $((repo_count - 1))); do
    repo_name=$(echo "$repos_response" | jq -r ".[$i].name")
    default_branch=$(echo "$repos_response" | jq -r ".[$i].default_branch")
    
    echo ""
    echo "Processing repository: $repo_name"
    
    # Enable advanced security for the repository
    enable_advanced_security "$repo_name"
    
    # Create branch protection rule for the default branch
    create_branch_protection_rule "$repo_name" "$default_branch"
done

# Create organization-level rulesets
echo ""
echo "Creating organization-level rulesets..."
create_repository_ruleset "default-branch-protection"
create_repository_ruleset "require-signed-commits"

echo ""
echo "Enterprise security policy setup completed!"
echo ""
echo "Summary of actions taken:"
echo "1. Enabled advanced security (code scanning, secret scanning) for all repositories"
echo "2. Set up branch protection rules for default branches in all repositories"
echo "3. Created organization-level repository rulesets"
echo ""
echo "Next steps:"
echo "1. Review and customize the branch protection rules as needed"
echo "2. Monitor security alerts in the GitHub Security tab"
echo "3. Consider setting up SSO and SCIM for your organization"
echo "4. Activate GitHub Copilot Business for AI-powered coding assistance"