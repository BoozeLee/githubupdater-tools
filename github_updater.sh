#!/bin/bash
# github_updater.sh

# This script helps automate the process of updating your GitHub projects

# Set variables
PROJECT_NAME="sentiment-analysis-bert"
GITHUB_USERNAME="BoozeLee"
REPO_NAME="sentiment-analysis-bert"

# Navigate to the project directory
cd /home/johnycash/ai-tools/githubupdater/sentiment-analysis-project

# Initialize git repository if it doesn't exist
if [ ! -d ".git" ]; then
    git init
    git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
fi

# Add all files
git add .

# Commit changes with a timestamp
git commit -m "Update: $(date)"

# Push to GitHub
git push -u origin main

echo "Project updated successfully!"

# Update GitHub profile README
cd /home/johnycash/ai-tools/githubupdater
git add README.md
git commit -m "Update profile README: $(date)"
git push -u origin main

echo "Profile README updated successfully!"