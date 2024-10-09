#!/bin/bash
# File Name: repo_status.sh
# Description: This script checks the status of a Git repository. 
#              It can take the repository path as a command-line argument or read it from a specified file.
# Author: Ajay Singh
# Version: 1.3
# Date: 20-05-2024

# Constants
DETAILS_FILE="repo_details.txt"

# Color Codes
COLOR_INFO="\033[1;32m"   # Green for info
COLOR_ERROR="\033[1;31m"  # Red for errors
COLOR_MAIN="\033[1;35m"   # Dark pink for repository path and branch name
COLOR_RESET="\033[0m"     # Reset color

# Display help message
show_help() {
    echo "Usage: $0 [-p repo_path] [-h]"
    echo "  -p repo_path    Git repository path (overrides $DETAILS_FILE)"
    echo "  -h              Show this help message"
    exit 0
}

# Log informational messages in green
log_info() {
    echo -e "${COLOR_INFO}INFO:${COLOR_RESET} $1" # Green text for info
}

# Log error messages in red and exit
log_error() {
    echo -e "${COLOR_ERROR}ERROR:${COLOR_RESET} $1" >&2 # Red text for errors
    exit 1
}

# Log repo path and branch name in Dark pink
log_repo_path() {
    echo -e "${COLOR_MAIN}REPO PATH:${COLOR_RESET} $1" # Dark pink text for repo path
}

log_branch_name() {
    echo -e "${COLOR_MAIN}BRANCH NAME:${COLOR_RESET} $1" # Dark pink text for branch name
}

# Check if Git is installed
check_git_installed() {
    command -v git &>/dev/null || log_error "Git is not installed. Install Git and try again."
}

# Read repository path from repo_details.txt
read_details_file() {
    if [[ ! -f "$DETAILS_FILE" ]]; then
        log_error "$DETAILS_FILE not found! Provide details via -p or create $DETAILS_FILE."
    fi
    repo_path_file=$(awk 'NR==1 {print $0}' "$DETAILS_FILE" | xargs) # Get first line as repo path
}

# Convert Windows-style path to Unix-style path for Git Bash
convert_path() {
    local path="$1"
    if [[ "$path" =~ ^([A-Z]): ]]; then
        path="/${BASH_REMATCH[1],,}/$(echo "${path:2}" | sed 's|\\|/|g')"
    fi
    echo "$path"
}

# Main logic
main() {
    local repo_path=""

    # Parse command-line options
    while getopts ":p:h" opt; do
        case "$opt" in
            p) repo_path=$(convert_path "$OPTARG") ;; # Convert and set repository path
            h) show_help ;;                             # Show help message
            *) log_error "Invalid option: -$OPTARG" ;; # Handle invalid options
        esac
    done

    # Read details from the file if not provided via command-line options
    read_details_file
    repo_path="${repo_path:-$repo_path_file}"  # Use details file path if command-line path is not set

    # Ensure the repo path is set
    if [[ -z "$repo_path" ]]; then
        log_error "Repository path is missing."
    fi

    # Check if the repo path exists
    if [[ ! -d "$repo_path" ]]; then
        log_error "Repository path not found: $repo_path"
    fi

    # Log the repo path in Dark pink
    log_repo_path "$repo_path"

    log_info "Navigating to repository"

    # Change to the repository directory and run git status
    (
        cd "$repo_path" || log_error "Failed to access directory: $repo_path"

        # Get current branch name
        branch_name=$(git rev-parse --abbrev-ref HEAD)
        
        # Log the branch name in Dark pink
        log_branch_name "$branch_name"

        log_info "Running git status"
        git status
    )
}

# Check if Git is installed
check_git_installed

# Execute main function
main "$@"
