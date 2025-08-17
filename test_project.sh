#!/bin/bash
# test_project.sh

# This script tests the sentiment analysis project

echo "Testing sentiment analysis project..."

# Navigate to the project directory
cd /home/johnycash/ai-tools/githubupdater/sentiment-analysis-project

# Create a virtual environment
echo "Creating virtual environment..."
python -m venv test_env

# Activate the virtual environment
echo "Activating virtual environment..."
source test_env/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# Test if the main script exists
if [ -f "main.py" ]; then
    echo "✓ main.py found"
else
    echo "✗ main.py not found"
fi

# Test if the requirements file exists
if [ -f "requirements.txt" ]; then
    echo "✓ requirements.txt found"
else
    echo "✗ requirements.txt not found"
fi

# Test if the README file exists
if [ -f "README.md" ]; then
    echo "✓ README.md found"
else
    echo "✗ README.md not found"
fi

# Test if the sample data file exists
if [ -f "sample_data.csv" ]; then
    echo "✓ sample_data.csv found"
else
    echo "✗ sample_data.csv not found"
fi

# Deactivate the virtual environment
echo "Deactivating virtual environment..."
deactivate

# Remove the test virtual environment
echo "Cleaning up..."
rm -rf test_env

echo "Project test completed!"