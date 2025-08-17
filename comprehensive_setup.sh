#!/bin/bash

# Comprehensive GitHub Account Setup Script

echo "Comprehensive GitHub Account Setup"
echo "=================================="
echo ""

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set."
    echo "Please run the setup script first:"
    echo "  /home/johnycash/ai-tools/githubupdater/setup_comprehensive_environment.sh"
    exit 1
fi

echo "Starting comprehensive GitHub account setup..."
echo ""

# 1. Enable Two-Factor Authentication
echo "1. Setting up Two-Factor Authentication..."
echo "Note: This requires manual steps. Please follow the instructions."
/home/johnycash/ai-tools/githubupdater/setup_2fa.sh

echo ""
read -p "Press Enter to continue to the next step..."

# 2. Create SECURITY.md files
echo "2. Creating SECURITY.md files in all repositories..."
/home/johnycash/ai-tools/githubupdater/create_security_files.sh

echo ""
read -p "Press Enter to continue to the next step..."

# 3. Enable GitHub Advanced Security
echo "3. Enabling GitHub Advanced Security features..."
/home/johnycash/ai-tools/githubupdater/enable_advanced_security.sh

echo ""
read -p "Press Enter to continue to the next step..."

# 4. Set up CI/CD with GitHub Actions
echo "4. Setting up CI/CD with GitHub Actions..."
/home/johnycash/ai-tools/githubupdater/setup_cicd.sh

echo ""
echo "Comprehensive GitHub account setup completed!"
echo ""
echo "Summary of actions taken:"
echo "1. Guided you through Two-Factor Authentication setup"
echo "2. Created SECURITY.md files in all repositories"
echo "3. Enabled GitHub Advanced Security features"
echo "4. Set up CI/CD workflows with GitHub Actions"
echo ""
echo "Manual steps still required:"
echo "- Verify that 2FA is properly enabled"
echo "- Review and customize the SECURITY.md files"
echo "- Review and customize the CI/CD workflows"
echo "- Monitor security alerts and notifications"