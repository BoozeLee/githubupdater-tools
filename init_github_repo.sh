#!/bin/bash
# init_github_repo.sh

# This script initializes the GitHub repository for the sentiment analysis project

# Set variables
REPO_NAME="sentiment-analysis-bert"
GITHUB_USERNAME="BoozeLee"

echo "Initializing GitHub repository for $REPO_NAME..."

# Navigate to the project directory
cd /home/johnycash/ai-tools/githubupdater/sentiment-analysis-project

# Initialize git repository
echo "Initializing git repository..."
git init

# Add all files
echo "Adding files to git..."
git add .

# Make the first commit
echo "Making initial commit..."
git commit -m "Initial commit: Sentiment analysis project with BERT"

# Add remote origin (you'll need to create the repository on GitHub first)
echo "Adding remote origin..."
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git

echo "Repository initialization complete!"
echo "Remember to create the remote repository on GitHub before pushing:"
echo "1. Go to https://github.com/new"
echo "2. Create a new repository named $REPO_NAME"
echo "3. Run 'git push -u origin main' to push the code"