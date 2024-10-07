#!/bin/bash
# Author: Ajay Singh
# Version: 1.2
# Date: 20-05-2024

# Constants
DETAILS_FILE="repo_details.txt"

# Display help message
show_help() {
    cat << EOF
Usage: $0 [-p repo_path] [-b branch_name] [-h]
  -p repo_path    Git repository path (overrides $DETAILS_FILE)
  -b branch_name  Branch to checkout (overrides $DETAILS_FILE)
  -h              Show this help message
EOF
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

# Ensure Git is installed
check_git_installed() {
    command -v git &> /dev/null || log_error "Git is not installed. Install Git and try again."
}

# Read repository and branch from repo_details.txt
read_details_file() {
    if [[ ! -f "$DETAILS_FILE" ]]; then
        log_error "$DETAILS_FILE not found! Provide details via -p or -b, or create $DETAILS_FILE."
    fi
    mapfile -t details < "$DETAILS_FILE"
    repo_path_file=$(xargs < <(echo "${details[0]}"))  # Trim whitespace
    branch_name_file=$(xargs < <(echo "${details[1]}"))  # Trim whitespace
}

# Convert Windows-style path to Unix-style path for Git Bash
convert_path() {
    local path="$1"
    [[ "$path" =~ ^([A-Z]): ]] && path="/${BASH_REMATCH[1],,}/$(echo "$path" | sed 's|\\|/|g' | sed 's|^[A-Z]:||')"
    echo "$path"
}

# Get the final repo path and branch name
get_repo_and_branch() {
    local repo_path="${1:-$repo_path_file}"
    local branch_name="${2:-$branch_name_file}"

    [[ -z "$repo_path" ]] && log_error "Repository path is missing in both command-line arguments and $DETAILS_FILE."
    [[ -z "$branch_name" ]] && log_error "Branch name is missing in both command-line arguments and $DETAILS_FILE."

    echo "$repo_path" "$branch_name"
}

# Main logic
main() {
    local repo_path="" branch_name=""

    # Parse command-line options
    while getopts ":p:b:h" opt; do
        case "$opt" in
            p) repo_path=$(convert_path "$OPTARG") ;;  # Convert and set repository path
            b) branch_name="$OPTARG" ;;                  # Set branch name
            h) show_help ;;                               # Show help message
            *) log_error "Invalid option: -$OPTARG" ;;  # Handle invalid options
        esac
    done

    # Read details from the file
    read_details_file

    # Get the final repo path and branch name
    read repo_path branch_name < <(get_repo_and_branch "$repo_path" "$branch_name")

    # Ensure Git is installed
    check_git_installed

    # Check if the repo path exists
    [[ ! -d "$repo_path" ]] && log_error "Repository path not found: $repo_path"

    log_info "Navigating to repository: $repo_path"

    # Change to the repository directory and check out the branch
    (
        cd "$repo_path" || log_error "Failed to access directory: $repo_path"

        log_info "Checking out branch: $branch_name"
        if git show-ref --verify --quiet refs/heads/"$branch_name"; then
            git checkout "$branch_name" && log_info "Successfully checked out branch: $branch_name"
        else
            log_error "Branch '$branch_name' does not exist in the repository."
        fi
    )
}

# Execute main function
main "$@"