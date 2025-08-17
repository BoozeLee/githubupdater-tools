#!/bin/bash
# weekly_update.sh

# This script helps automate the process of weekly updates to your GitHub projects

# Set variables
GITHUB_USERNAME="BoozeLee"
DATE=$(date +"%Y-%m-%d")

echo "Starting weekly GitHub update for $DATE"

# Navigate to the sentiment analysis project directory
cd /home/johnycash/ai-tools/githubupdater/sentiment-analysis-project

# Check if there are any changes
if [[ -n $(git status -s) ]]; then
    echo "Changes detected in sentiment analysis project. Committing..."
    
    # Add all files
    git add .
    
    # Commit changes with a timestamp
    git commit -m "Weekly update: $DATE - Improvements and bug fixes"
    
    # Push to GitHub
    git push origin main
    
    echo "Sentiment analysis project updated successfully!"
else
    echo "No changes detected in sentiment analysis project."
fi

# Update GitHub profile README
cd /home/johnycash/ai-tools/githubupdater

# Check if there are any changes
if [[ -n $(git status -s) ]]; then
    echo "Changes detected in profile README. Committing..."
    
    # Add README
    git add README.md
    
    # Commit changes with a timestamp
    git commit -m "Weekly profile update: $DATE - Skills and projects refresh"
    
    # Push to GitHub
    git push origin main
    
    echo "Profile README updated successfully!"
else
    echo "No changes detected in profile README."
fi

echo "Weekly update process completed!"