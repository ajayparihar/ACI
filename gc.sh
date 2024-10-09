#!/bin/bash
# File Name: gc.sh
# Description: This script executes a specified Git command in a designated Git repository. 
#              It can take the repository path and Git command as command-line arguments 
#              or read them from a specified file.
# Author: Ajay Singh
# Version: 1.1
# Date: 20-10-2024

# Color Codes
COLOR_INFO="\033[1;32m"   # Green for info
COLOR_ERROR="\033[1;31m"  # Red for errors
COLOR_MAIN="\033[1;35m"   # Dark pink for repository path and branch name
COLOR_RESET="\033[0m"     # Reset color

# Constants
DETAILS_FILE="repo_details.txt"

# Display help message
show_help() {
    echo "Usage: $0 [--git <git_command>] [-p repo_path] [-h]"
    echo "  --git <git_command>    Run a Git command in the repository."
    echo "  -p <repo_path>         Specify Git repository path (overrides $DETAILS_FILE)"
    echo "  -h                     Show this help message"
    exit 0
}

# Log informational messages in green
log_info() {
    echo -e "${COLOR_INFO}INFO:${COLOR_RESET} $1"
}

# Log error messages in red and exit
log_error() {
    echo -e "${COLOR_ERROR}ERROR:${COLOR_RESET} $1" >&2
    exit 1
}

# Log repository path in dark pink
log_repo_info() {
    echo -e "${COLOR_MAIN}REPO PATH:${COLOR_RESET} $1"
}

# Log branch name in dark pink
log_branch_info() {
    echo -e "${COLOR_MAIN}BRANCH NAME:${COLOR_RESET} $1"
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

    repo_path_file=$(awk 'NR==1 {print $0}' "$DETAILS_FILE" | xargs)

    # Check if the repo path is empty
    if [[ -z "$repo_path_file" ]]; then
        log_error "$DETAILS_FILE is empty! Provide a valid repository path."
    fi
}

# Convert Windows-style path to Unix-style path for Git Bash
convert_path() {
    local path="$1"
    [[ "$path" =~ ^([A-Z]): ]] && path="/${BASH_REMATCH[1],,}/$(echo "$path" | sed 's|\\|/|g' | sed 's|^[A-Z]:||')"
    echo "$path"
}

# Main logic
main() {
    local repo_path=""
    local git_command=()

    # Parse command-line options
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --git)
                shift
                # Capture everything after --git as part of the Git command
                while [[ "$#" -gt 0 ]]; do
                    git_command+=("$1")
                    shift
                done
                ;;
            -p)
                shift
                repo_path=$(convert_path "$1")
                shift
                ;;
            -h)
                show_help
                ;;
            *)
                log_error "Invalid option: $1"
                ;;
        esac
    done

    # Read details from the file if not provided via command-line options
    read_details_file
    repo_path="${repo_path:-$repo_path_file}"

    # Ensure the repo path is set
    if [[ -z "$repo_path" ]]; then
        log_error "Repository path is missing."
    fi

    # Check if the repo path exists
    if [[ ! -d "$repo_path" ]]; then
        log_error "Repository path not found: $repo_path"
    fi

    log_info "Navigating to repository"  # Log info message first
    log_repo_info "$repo_path"  # Log repository path in dark pink

    # Change to the repository directory
    (
        cd "$repo_path" || log_error "Failed to access directory: $repo_path"

        # Determine the current branch name
        branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || log_error "Failed to get current branch name."
        
        # Log branch name in dark pink after changing the directory
        log_branch_info "$branch_name"

        # Run the Git command
        if [[ ${#git_command[@]} -eq 0 ]]; then
            # Default to 'git status' if no --git command is provided
            git_command=("status")
        fi

        log_info "Running command: git ${git_command[*]}"
        git "${git_command[@]}" || log_error "Command failed: git ${git_command[*]}"
    )
}

# Check if Git is installed
check_git_installed

# Execute main function
main "$@"
