#!/bin/bash
# Author: Ajay Singh
# Version: 1.1
# Date: 20-05-2024

# Function to log and display error messages
log_error() {
    echo "Error: $1"
    exit 1
}

# Function to change directory to the repository
navigate_to_repo() {
    # Check if the repo_path.txt file exists
    if [ ! -f "repo_path.txt" ]; then
        log_error "repo_path.txt not found!"
    fi

    # Read the repository path
    repo_path=$(<repo_path.txt)

    # Check if the repository path exists and navigate to it
    if [ -d "$repo_path" ]; then
        echo "Navigating to the repository folder: $repo_path"
        cd "$repo_path" || log_error "Failed to navigate to $repo_path"
    else
        log_error "Repository path not found: $repo_path"
    fi
}

# Function to update git status
update_git_status() {
    echo "Updating Git status..."
    git status || log_error "Failed to update Git status"
}

# Main script execution
navigate_to_repo
update_git_status
