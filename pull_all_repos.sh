#!/bin/bash

# Configurable Git Repository Pull Script
# This script pulls specific branches from configured repositories
# Designed to run twice daily at 12:00 (noon and midnight)

# Configuration - Edit these arrays to change repositories and branches
# Format: "repo_name:branch_name"
REPO_CONFIG=(
    "api:dev"
    "web-app:dev"
    "core:main"
    "pv-expected-energy:main"
    "docs-mdbook:main"
)

# Base directory where repositories are located (adjust as needed)
BASE_DIR="$HOME/Programs"

# Logging configuration
LOG_FILE="$HOME/Programs/_cron/logs/git_pull.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages
log_message() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

# Function to pull a specific branch from a repository
pull_repo() {
    local repo_name=$1
    local branch_name=$2
    local repo_path="$BASE_DIR/$repo_name"

    log_message "Starting pull for $repo_name (branch: $branch_name)"

    if [ ! -d "$repo_path" ]; then
        log_message "ERROR: Repository directory $repo_path does not exist"
        return 1
    fi

    cd "$repo_path" || {
        log_message "ERROR: Failed to change to directory $repo_path"
        return 1
    }

    # Check if it's a git repository
    if [ ! -d ".git" ]; then
        log_message "ERROR: $repo_path is not a git repository"
        return 1
    fi

    # Fetch latest changes
    log_message "Fetching latest changes for $repo_name..."
    if ! git fetch origin; then
        log_message "ERROR: Failed to fetch from origin for $repo_name"
        return 1
    fi

    # Get current branch
    current_branch=$(git branch --show-current)

    # Switch to target branch if not already on it
    if [ "$current_branch" != "$branch_name" ]; then
        log_message "Switching from $current_branch to $branch_name in $repo_name"
        if ! git checkout "$branch_name"; then
            log_message "ERROR: Failed to checkout branch $branch_name in $repo_name"
            return 1
        fi
    fi

    # Pull the latest changes
    log_message "Pulling latest changes for $repo_name on branch $branch_name"
    if git pull origin "$branch_name"; then
        log_message "SUCCESS: Updated $repo_name to latest $branch_name"
        return 0
    else
        log_message "ERROR: Failed to pull $branch_name for $repo_name"
        return 1
    fi
}

# Main execution
main() {
    log_message "=== Starting automated git pull process ==="
    log_message "Configured repositories:"

    for config in "${REPO_CONFIG[@]}"; do
        repo_name="${config%%:*}"
        branch_name="${config##*:}"
        log_message "  - $repo_name: $branch_name"
    done

    local success_count=0
    local total_count=${#REPO_CONFIG[@]}

    # Process each repository
    for config in "${REPO_CONFIG[@]}"; do
        repo_name="${config%%:*}"
        branch_name="${config##*:}"

        if pull_repo "$repo_name" "$branch_name"; then
            ((success_count++))
        fi

        log_message "---"
    done

    log_message "=== Pull process completed ==="
    log_message "Results: $success_count/$total_count repositories updated successfully"

    if [ $success_count -eq $total_count ]; then
        log_message "All repositories updated successfully!"
        exit 0
    else
        log_message "Some repositories failed to update. Check logs above."
        exit 1
    fi
}

# Run the main function
main "$@"
