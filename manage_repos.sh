#!/bin/bash
# manage_repos.sh - Script to manage all GitHub repositories with bakerstreet concept

# Configuration
GITHUB_USERNAME="BoozeLee"
PROJECTS_DIR="/home/johnycash/ai-tools/githubupdater"
REPO_LIST_FILE="$PROJECTS_DIR/repo_list.txt"

# Function to display help
show_help() {
    echo "GitHub Repository Manager"
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  status     Show status of all repositories"
    echo "  rename     Help rename repositories with descriptive names"
    echo "  readme     Check and update README files"
    echo "  license    Standardize licenses across repositories"
    echo "  automate   Set up automation for regular updates"
    echo "  list       List all repositories"
    echo "  help       Display this help message"
}

# Function to list all repositories
list_repos() {
    echo "=== GitHub Repositories ==="
    # This would ideally fetch from GitHub API, but for now we'll use local directory structure
    echo "1. sentiment-analysis-bert"
    echo "2. qwen-polymorphic-sentiment-analysis (symmetrical-waffle)"
    echo "3. githubupdater-tools"
    echo "4. Baker-Street-Laboratory"
    echo "5. dyad"
    echo "6. voidshatterecho"
    echo "7. MIT License"
    echo "8. GNU Lesser General Public License v3.0"
}

# Function to check repository status
check_status() {
    echo "=== Repository Status ==="
    
    # Check sentiment-analysis-bert
    if [ -d "$PROJECTS_DIR/sentiment-analysis-project" ]; then
        cd "$PROJECTS_DIR/sentiment-analysis-project"
        if [ -d ".git" ]; then
            echo "✓ sentiment-analysis-bert: Git repository initialized"
            if [[ -n $(git status -s) ]]; then
                echo "  → Changes detected, needs commit"
            else
                echo "  → No changes pending"
            fi
        else
            echo "✗ sentiment-analysis-bert: Git repository not initialized"
        fi
    else
        echo "✗ sentiment-analysis-bert: Project directory not found"
    fi
    
    # Check qwen-polymorphic-sentiment-analysis
    if [ -d "$PROJECTS_DIR/qwen-polymorphic-sentiment-analysis" ]; then
        cd "$PROJECTS_DIR/qwen-polymorphic-sentiment-analysis"
        if [ -d ".git" ]; then
            echo "✓ qwen-polymorphic-sentiment-analysis: Git repository initialized"
            if [[ -n $(git status -s) ]]; then
                echo "  → Changes detected, needs commit"
            else
                echo "  → No changes pending"
            fi
        else
            echo "✗ qwen-polymorphic-sentiment-analysis: Git repository not initialized"
        fi
    else
        echo "✗ qwen-polymorphic-sentiment-analysis: Project directory not found"
    fi
    
    # Check githubupdater-tools
    cd "$PROJECTS_DIR"
    if [ -d ".git" ]; then
        echo "✓ githubupdater-tools: Git repository initialized"
        if [[ -n $(git status -s) ]]; then
            echo "  → Changes detected, needs commit"
        else
            echo "  → No changes pending"
        fi
    else
        echo "✗ githubupdater-tools: Git repository not initialized"
    fi
}

# Function to help rename repositories
rename_repos() {
    echo "=== Repository Renaming Helper ==="
    echo "Based on the organization plan, here are recommended renames:"
    echo ""
    echo "1. Rename 'symmetrical-waffle' to 'qwen-polymorphic-sentiment-analysis'"
    echo "   (Already done locally)"
    echo ""
    echo "2. Rename 'MIT License' to a descriptive name based on its content"
    echo ""
    echo "3. Rename 'GNU Lesser General Public License v3.0' to a descriptive name based on its content"
    echo ""
    echo "Use the GitHub website to rename repositories:"
    echo "1. Go to https://github.com/$GITHUB_USERNAME"
    echo "2. Click on the repository you want to rename"
    echo "3. Go to Settings"
    echo "4. Scroll to 'Repository name' section"
    echo "5. Enter the new name and click 'Rename'"
}

# Function to check and update README files
check_readmes() {
    echo "=== README Files Check ==="
    
    # Check sentiment-analysis-bert README
    if [ -f "$PROJECTS_DIR/sentiment-analysis-project/README.md" ]; then
        echo "✓ sentiment-analysis-bert: README.md found"
    else
        echo "✗ sentiment-analysis-bert: README.md missing"
        echo "  → Create a README.md with project description, setup instructions, and usage examples"
    fi
    
    # Check qwen-polymorphic-sentiment-analysis README
    if [ -f "$PROJECTS_DIR/qwen-polymorphic-sentiment-analysis/README.md" ]; then
        echo "✓ qwen-polymorphic-sentiment-analysis: README.md found"
    else
        echo "✗ qwen-polymorphic-sentiment-analysis: README.md missing"
        echo "  → Create a README.md with project description, setup instructions, and usage examples"
    fi
    
    # Check main profile README
    if [ -f "$PROJECTS_DIR/README.md" ]; then
        echo "✓ Profile README.md found"
        echo "  → Review and update with latest projects and skills"
    else
        echo "✗ Profile README.md missing"
        echo "  → Create a profile README.md with professional introduction and project showcase"
    fi
}

# Function to standardize licenses
standardize_licenses() {
    echo "=== License Standardization ==="
    echo "Recommended license approach based on project type:"
    echo ""
    echo "AI/ML Research Projects:"
    echo "  - Use Research and Educational Software License"
    echo "  - Applies to: sentiment-analysis-bert, qwen-polymorphic-sentiment-analysis"
    echo ""
    echo "Tools and Utilities:"
    echo "  - Use MIT License"
    echo "  - Applies to: githubupdater-tools"
    echo ""
    echo "Other Projects:"
    echo "  - Evaluate on a case-by-case basis"
    echo "  - Applies to: Baker-Street-Laboratory, dyad, voidshatterecho"
    echo ""
    echo "Empty/Placeholder Repositories:"
    echo "  - Remove repositories that contain only license files"
    echo "  - Applies to: 'MIT License', 'GNU Lesser General Public License v3.0'"
}

# Function to set up automation
setup_automation() {
    echo "=== Automation Setup ==="
    echo "1. Weekly update script: $PROJECTS_DIR/weekly_update.sh"
    echo "2. Cron job setup script: $PROJECTS_DIR/setup_cron.sh"
    echo ""
    echo "To set up automation:"
    echo "  a. Review and modify weekly_update.sh for all your repositories"
    echo "  b. Run ./setup_cron.sh to schedule weekly updates"
    echo ""
    echo "Current automation status:"
    cd "$PROJECTS_DIR"
    if crontab -l >/dev/null 2>&1; then
        echo "✓ Cron jobs are set up"
        echo "  → $(crontab -l | wc -l) job(s) scheduled"
    else
        echo "✗ No cron jobs found"
        echo "  → Run ./setup_cron.sh to set up weekly updates"
    fi
}

# Main script logic
case "$1" in
    status)
        check_status
        ;;
    rename)
        rename_repos
        ;;
    readme)
        check_readmes
        ;;
    license)
        standardize_licenses
        ;;
    automate)
        setup_automation
        ;;
    list)
        list_repos
        ;;
    help|"")
        show_help
        ;;
    *)
        echo "Invalid option: $1"
        show_help
        exit 1
        ;;
esac