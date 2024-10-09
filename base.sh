#!/bin/bash
# File Name: base.sh
# Description: This script automates the process of committing and pushing changes 
#              to a Git repository. It reads the repository path and branch name from 
#              a file, optionally takes an inline commit message, and commits changes 
#              to the repository.
# Author: Ajay Singh
# Version: 1.3
# Date: 20-05-2024

# Color Codes
COLOR_INFO="\033[1;32m"   # Green for info
COLOR_ERROR="\033[1;31m"  # Red for errors
COLOR_MAIN="\033[1;35m"   # Dark pink for repository path and branch name
COLOR_RESET="\033[0m"     # Reset color

# Constants
DETAILS_FILE="repo_details.txt"
COMMIT_MESSAGE_FILE="commit_message.txt"

# Display help message
show_help() {
    cat << EOF
Usage: $0 [-m commit_message] [-h]
  -m commit_message  Inline commit message (overrides $COMMIT_MESSAGE_FILE)
  -h                 Show this help message
EOF
    exit 0
}

# Log informational messages in green
log_info() {
    echo -e "${COLOR_INFO}INFO:${COLOR_RESET} $1"  # Green text for info
}

# Log error messages in red and exit
log_error() {
    echo -e "${COLOR_ERROR}ERROR:${COLOR_RESET} $1" >&2  # Red text for errors
    exit 1
}

# Log the repository path and branch in pink (COLOR_MAIN)
log_repo_and_branch() {
    echo -e "${COLOR_MAIN}REPO PATH:${COLOR_RESET} $1"   # Pink text for repository path
    echo -e "${COLOR_MAIN}BRANCH NAME:${COLOR_RESET} $2" # Pink text for branch name
}

# Check if Git is installed
check_git_installed() {
    command -v git &> /dev/null || log_error "Git is not installed. Install Git and try again."
}

# Read repository details from the repo_details.txt file
read_repository_details() {
    if [[ ! -f "$DETAILS_FILE" ]]; then
        log_error "$DETAILS_FILE not found! Provide details via command line or create $DETAILS_FILE."
    fi

    mapfile -t details < "$DETAILS_FILE"
    repo_path=$(echo "${details[0]}" | xargs)  # Trim whitespace
    branch_name=$(echo "${details[1]}" | xargs)  # Trim whitespace
}

# Convert Windows-style path to Unix-style path for Git Bash
convert_windows_path_to_unix() {
    local path="$1"
    if [[ "$path" =~ ^([A-Z]): ]]; then
        path="/${BASH_REMATCH[1],,}/$(echo "$path" | sed 's|\\|/|g' | sed 's|^[A-Z]:||')"
    fi
    echo "$path"
}

# Get the commit message from the commit_message.txt file or the inline argument
get_commit_message() {
    local inline_commit_message="$1"

    if [[ ! -f "$COMMIT_MESSAGE_FILE" && -z "$inline_commit_message" ]]; then
        log_error "$COMMIT_MESSAGE_FILE not found! Provide a valid commit message or use -m option."
    fi

    if [[ -n "$inline_commit_message" ]]; then
        echo "$inline_commit_message"  # Use the inline commit message
    else
        commit_message=$(<"$COMMIT_MESSAGE_FILE")
        commit_message=$(echo "$commit_message" | tr -d '\n\r')  # Trim newlines
        [[ -z "$commit_message" ]] && log_error "Commit message is empty after trimming!"
        echo "$commit_message"
    fi
}

# Main script logic
main() {
    local commit_message=""

    # Parse command-line options
    while getopts ":m:h" opt; do
        case "$opt" in
            m) commit_message="$OPTARG" ;;  # Set inline commit message
            h) show_help ;;                  # Show help message
            *) log_error "Invalid option: -$OPTARG" ;;  # Handle invalid options
        esac
    done

    # Read repository details from file
    read_repository_details

    # Convert the repository path to Unix format
    repo_path=$(convert_windows_path_to_unix "$repo_path")

    # Log the repository path and branch name in pink
    log_repo_and_branch "$repo_path" "$branch_name"

    # Get the commit message
    commit_message=$(get_commit_message "$commit_message")

    # Ensure Git is installed
    check_git_installed

    # Validate the repository path
    [[ ! -d "$repo_path" ]] && log_error "Repository path not found: $repo_path"

    log_info "Navigating to repository: $repo_path"
    cd "$repo_path" || log_error "Failed to access directory: $repo_path"

    log_info "Adding all files..."
    git add . || log_error "Failed to add files to the Git index!"

    # Prepare the commit message with the baseline
    local baseline_message="_baseline"

    # Execute the git commit
    log_info "Executing git commit -m '$commit_message$baseline_message'"
    git commit -m "$commit_message$baseline_message" || log_error "Git commit failed!"

    log_info "Pushing changes to the branch..."
    git push origin "$branch_name" || log_error "Git push failed!"

    log_info "Updating repository status..."
    git status
}

# Execute the main function
main "$@"
