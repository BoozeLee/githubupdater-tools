#!/bin/bash

# Script to transfer repositories from personal account to enterprise organization

echo "Transferring Repositories to Enterprise Organization"
echo "===================================================="
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
    echo "Please create an organization first."
    exit 1
fi

# Get the first organization (Bakery-street-projct)
org_name=$(echo "$orgs_response" | jq -r '.[0].login')
echo "✅ Working with organization: $org_name"

# Get list of personal repositories
echo "Fetching list of your personal repositories..."
personal_repos_response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
    "https://api.github.com/user/repos?per_page=100")

repo_count=$(echo "$personal_repos_response" | jq -r 'length')
echo "Found $repo_count personal repositories"

# Display repositories
echo ""
echo "Your personal repositories:"
for i in $(seq 0 $((repo_count - 1))); do
    repo_name=$(echo "$personal_repos_response" | jq -r ".[$i].name")
    repo_private=$(echo "$personal_repos_response" | jq -r ".[$i].private")
    privacy_status=$(if [ "$repo_private" = "true" ]; then echo "private"; else echo "public"; fi)
    echo "  $((i+1)). $repo_name ($privacy_status)"
done

# Function to transfer a repository
transfer_repo() {
    local repo_name=$1
    
    echo ""
    echo "Transferring repository: $repo_name"
    
    # Transfer repository using GitHub API
    response=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/$user/$repo_name/transfer \
        -X POST \
        -d "{
            \"new_owner\": \"$org_name\"
        }")
    
    # Check if the repository was transferred successfully
    if echo "$response" | jq -e '.name' > /dev/null 2>&1; then
        echo "✅ Repository transferred successfully: $repo_name"
        return 0
    else
        error_message=$(echo "$response" | jq -r '.message // "Unknown error"')
        echo "❌ Failed to transfer repository: $repo_name. Error: $error_message"
        
        # Check if it's a permissions issue
        if echo "$error_message" | grep -q "forked repositories"; then
            echo "   Note: Forked repositories cannot be directly transferred."
            echo "   Consider creating a new repository in the organization and pushing the code there."
        fi
        
        return 1
    fi
}

# Ask user which repositories to transfer
echo ""
echo "Which repositories would you like to transfer?"
echo "1. All repositories"
echo "2. Select specific repositories"
echo "3. None (exit)"
echo ""

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo "Transferring all repositories..."
        success_count=0
        fail_count=0
        
        for i in $(seq 0 $((repo_count - 1))); do
            repo_name=$(echo "$personal_repos_response" | jq -r ".[$i].name")
            if transfer_repo "$repo_name"; then
                ((success_count++))
            else
                ((fail_count++))
            fi
        done
        
        echo ""
        echo "Transfer complete: $success_count succeeded, $fail_count failed"
        ;;
    2)
        echo "Enter the numbers of repositories to transfer (e.g., 1 3 5):"
        read -p "Repository numbers: " repo_numbers
        
        success_count=0
        fail_count=0
        
        for num in $repo_numbers; do
            # Validate input
            if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "$repo_count" ]; then
                echo "Invalid repository number: $num"
                continue
            fi
            
            # Get repository name by index
            index=$((num - 1))
            repo_name=$(echo "$personal_repos_response" | jq -r ".[$index].name")
            
            if transfer_repo "$repo_name"; then
                ((success_count++))
            else
                ((fail_count++))
            fi
        done
        
        echo ""
        echo "Transfer complete: $success_count succeeded, $fail_count failed"
        ;;
    3)
        echo "No repositories transferred."
        ;;
    *)
        echo "Invalid choice. No repositories transferred."
        ;;
esac

# Provide information about next steps
echo ""
echo "Next steps:"
echo "1. Verify that the transferred repositories are accessible in your organization"
echo "2. Update any CI/CD workflows or scripts that reference the old repository URLs"
echo "3. Update any documentation that references the old repository URLs"
echo "4. Consider setting up team access controls for the transferred repositories"
echo "5. Review and customize repository settings in the organization context"

echo ""
echo "Note: If you have any forked repositories, they cannot be directly transferred."
echo "For those, you'll need to create new repositories in the organization and push the code."