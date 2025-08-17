#!/bin/bash

# Set the GitHub token from file
export GITHUB_TOKEN=$(cat /home/johnycash/.github_token)

# Run the transfer script with input "1" to transfer all repositories
echo "1" | /home/johnycash/ai-tools/githubupdater/transfer_repos_to_org.sh