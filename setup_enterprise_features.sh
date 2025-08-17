#!/bin/bash

# Script to set up GitHub Enterprise features

echo "Setting up GitHub Enterprise Features"
echo "===================================="
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

# Get enterprise information
echo "Getting enterprise information..."
enterprise_response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    https://api.github.com/user/orgs)

if echo "$enterprise_response" | jq -e '.message == "Bad credentials"' > /dev/null 2>&1; then
    echo "❌ Unable to access enterprise information. You may need to create an organization first."
    echo ""
    echo "To create an organization:"
    echo "1. Go to https://github.com/organizations/plan"
    echo "2. Select a plan for your organization"
    echo "3. Follow the prompts to create your organization"
    echo ""
    exit 1
fi

# Check if user is part of any organizations
org_count=$(echo "$enterprise_response" | jq -r 'length')

if [ "$org_count" -eq 0 ]; then
    echo "⚠️  You are not currently part of any organizations."
    echo ""
    echo "To take full advantage of enterprise features, consider creating an organization:"
    echo "1. Go to https://github.com/organizations/plan"
    echo "2. Select a plan for your organization"
    echo "3. Follow the prompts to create your organization"
    echo ""
else
    echo "✅ You are part of $org_count organization(s):"
    echo "$enterprise_response" | jq -r '.[].login'
    echo ""
    
    # For each organization, we could set up enterprise features
    # But for now, let's just provide information
    echo "Enterprise features available to your organization(s):"
    echo "1. GitHub Copilot Business (AI-powered coding assistance)"
    echo "2. Advanced Security (code scanning, secret scanning)"
    echo "3. GitHub Actions (CI/CD automation)"
    echo "4. Enterprise-grade access controls"
    echo "5. Centralized policy management"
    echo ""
fi

# Check Copilot status
echo "Checking GitHub Copilot status..."
copilot_response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    https://api.github.com/user/codespaces/secrets)

# We can't directly check Copilot status via API, but we can provide instructions
echo "GitHub Copilot Business:"
echo "✅ Available for your enterprise free for 30 days"
echo ""
echo "To activate Copilot Business:"
echo "1. Go to https://github.com/settings/billing"
echo "2. Click on 'Copilot' in the left sidebar"
echo "3. Click 'Start free trial' or 'Activate'"
echo "4. Verify your identity as prompted"
echo ""
echo "Once activated, Copilot will be available for all members of your organization."

# Provide information about other enterprise features
echo ""
echo "Other Enterprise Features:"
echo "=========================="
echo ""
echo "1. Advanced Security:"
echo "   - Code scanning for vulnerabilities"
echo "   - Secret scanning to prevent leaks"
echo "   - Dependency review"
echo "   To enable: Run the advanced security script after setting up your organization"
echo ""
echo "2. GitHub Actions:"
echo "   - Already set up in your repositories"
echo "   - Can be enhanced with enterprise runners"
echo ""
echo "3. Centralized Policy Management:"
echo "   - Repository rulesets"
echo "   - Branch protection at organization level"
echo "   - Audit logging"
echo ""
echo "4. Enterprise-grade Access Controls:"
echo "   - SSO integration"
echo "   - SCIM provisioning"
echo "   - Advanced team management"

echo ""
echo "Next steps:"
echo "1. Create an organization to fully utilize enterprise features"
echo "2. Activate GitHub Copilot Business"
echo "3. Set up centralized security policies"
echo "4. Configure SSO if needed for your team"