#!/bin/bash

# Script to enable Two-Factor Authentication (2FA) for GitHub account

echo "GitHub Two-Factor Authentication Setup"
echo "======================================"
echo ""

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set."
    echo "Please run the setup script first:"
    echo "  /home/johnycash/ai-tools/githubupdater/setup_comprehensive_environment.sh"
    exit 1
fi

echo "Note: 2FA setup requires manual steps through the GitHub website."
echo "This script will guide you through the process."
echo ""

# Get current 2FA status
echo "Checking current 2FA status..."
user_response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    https://api.github.com/user)

two_factor_enabled=$(echo "$user_response" | jq -r '.two_factor_authentication')

if [ "$two_factor_enabled" = "true" ]; then
    echo "✅ Two-Factor Authentication is already enabled for your account."
    exit 0
else
    echo "❌ Two-Factor Authentication is not currently enabled."
fi

echo ""
echo "To enable 2FA, please follow these steps:"
echo ""
echo "1. Go to https://github.com/settings/security"
echo "2. Scroll down to 'Two-factor authentication' section"
echo "3. Click 'Enable two-factor authentication'"
echo "4. Choose your preferred method:"
echo "   - Authenticator app (recommended)"
echo "   - SMS text messages"
echo "5. Follow the on-screen instructions to complete setup"
echo "6. Save your recovery codes in a secure location"
echo ""
echo "Important: After enabling 2FA, you may need to re-authenticate with GitHub CLI:"
echo "   gh auth refresh"
echo ""

read -p "Press Enter to continue after setting up 2FA, or 'q' to quit: " response
if [ "$response" = "q" ]; then
    exit 0
fi

# Verify 2FA is now enabled
echo "Verifying 2FA status..."
user_response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    https://api.github.com/user)

two_factor_enabled=$(echo "$user_response" | jq -r '.two_factor_authentication')

if [ "$two_factor_enabled" = "true" ]; then
    echo "✅ Two-Factor Authentication is now enabled for your account."
else
    echo "⚠️  Two-Factor Authentication does not appear to be enabled yet."
    echo "Please complete the setup process on GitHub's website."
fi