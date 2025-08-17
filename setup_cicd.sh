#!/bin/bash

# Script to set up basic CI/CD with GitHub Actions

echo "Setting up CI/CD with GitHub Actions"
echo "===================================="
echo ""

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set."
    echo "Please run the setup script first:"
    echo "  /home/johnycash/ai-tools/githubupdater/setup_comprehensive_environment.sh"
    exit 1
fi

# List all repositories
echo "Fetching list of repositories..."
repos=$(gh repo list --limit 1000 | awk '{print $1}')

# Function to set up CI/CD for a repository
setup_cicd() {
    local repo=$1
    echo "Setting up CI/CD for: $repo"
    
    # Create a temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Clone the repository
    echo "Cloning repository..."
    git clone "https://BoozeLee444:$GITHUB_TOKEN@github.com/$repo.git" .
    
    # Create .github/workflows directory if it doesn't exist
    mkdir -p .github/workflows
    
    # Check if any workflow already exists
    if [ -n "$(ls -A .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null)" ]; then
        echo "CI/CD workflows already exist in $repo, skipping..."
        cd ..
        rm -rf "$temp_dir"
        return 0
    fi
    
    # Create a basic CI workflow based on the repository type
    if [ -f "requirements.txt" ]; then
        # Python project
        cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, "3.10", "3.11"]

    steps:
    - uses: actions/checkout@v3
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest
    - name: Test with pytest
      run: |
        pytest
EOF
        echo "Created Python CI workflow for $repo"
        
    elif [ -f "package.json" ]; then
        # Node.js project
        cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]

    steps:
    - uses: actions/checkout@v3
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    - run: npm ci
    - run: npm test
EOF
        echo "Created Node.js CI workflow for $repo"
        
    elif [ -f "Gemfile" ]; then
        # Ruby project
        cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby-version: [2.7, 3.0, 3.1]

    steps:
    - uses: actions/checkout@v3
    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: ${{ matrix.ruby-version }}
        bundler-cache: true
    - name: Run tests
      run: bundle exec rake
EOF
        echo "Created Ruby CI workflow for $repo"
        
    else
        # Generic workflow for other project types
        cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - name: Run basic checks
      run: |
        echo "No specific language detected, running generic checks"
        # Add your generic checks here
EOF
        echo "Created generic CI workflow for $repo"
    fi
    
    # Add the workflow file to the repository
    git add .github/workflows/ci.yml
    
    # Configure git user information
    git config --global user.email "kiliaanv2@gmail.com"
    git config --global user.name "BoozeLee444"
    
    # Make a commit
    git commit -m "Add CI workflow with GitHub Actions"
    
    # Push the commit
    echo "Pushing CI workflow to $repo..."
    git push
    
    # Clean up
    cd ..
    rm -rf "$temp_dir"
    
    echo "CI/CD workflow created and pushed to $repo"
    echo ""
}

# Process each repository
for repo in $repos; do
    setup_cicd "$repo"
done

echo "CI/CD setup completed for all repositories."