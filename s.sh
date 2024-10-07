#!/bin/bash
# Author: Ajay Singh
# Version: 1.2
# Date: 20-05-2024

# Constants
DETAILS_FILE="repo_details.txt"

# Display help message
show_help() {
    echo "Usage: $0 [-p repo_path] [-h]"
    echo "  -p repo_path    Git repository path (overrides repo_details.txt)"
    echo "  -h              Show this help message"
    exit 0
}

# Log informational messages in green
log_info() {
    echo -e "\033[1;32mINFO:\033[0m $1"  # Green text for info
}

# Log error messages in red and exit
log_error() {
    echo -e "\033[1;31mERROR:\033[0m $1" >&2  # Red text for errors
    exit 1
}

# Check if Git is installed
check_git_installed() {
    command -v git &> /dev/null || { log_error "Git is not installed. Install Git and try again."; exit 1; }
}

# Read repository path from repo_details.txt
read_details_file() {
    if [[ ! -f "$DETAILS_FILE" ]]; then
        log_error "$DETAILS_FILE not found! Provide details via -p or create $DETAILS_FILE."
        exit 1
    fi
    repo_path_file=$(awk 'NR==1 {print $0}' "$DETAILS_FILE" | xargs)  # Get first line as repo path
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

    # Parse command-line options
    while getopts ":p:h" opt; do
        case "$opt" in
            p) repo_path=$(convert_path "$OPTARG") ;;  # Convert and set repository path
            h) show_help ;;                               # Show help message
            *) log_error "Invalid option: -$OPTARG"; exit 2 ;;  # Handle invalid options
        esac
    done

    # Read details from the file if not provided via command-line options
    read_details_file
    repo_path="${repo_path:-$repo_path_file}"

    # Ensure the repo path is set
    if [[ -z "$repo_path" ]]; then
        log_error "Repository path is missing."
        exit 1
    fi

    # Check if the repo path exists
    if [[ ! -d "$repo_path" ]]; then
        log_error "Repository path not found: $repo_path"
        exit 1
    fi

    log_info "Navigating to repository: $repo_path"

    # Change to the repository directory and run git status
    (
        cd "$repo_path" || { log_error "Failed to access directory: $repo_path"; exit 1; }

        log_info "Running git status"
        git status
    )
}

# Execute main function
main "$@"
