#!/bin/bash
# File Name: reset.sh
# Description: This script resets a specified number of commits on a given branch of a Git repository. 
#              It can take the repository path, branch name, and number of commits as command-line arguments 
#              or read the repository path from a specified file.
# Author: Ajay Singh
# Version: 1.3
# Date: 09-10-2024

# Constants
DETAILS_FILE="repo_details.txt"

# Color Codes
COLOR_INFO="\033[1;32m"   # Green for info
COLOR_ERROR="\033[1;31m"  # Red for errors
COLOR_MAIN="\033[1;35m"   # Dark pink for repository path and branch name
COLOR_RESET="\033[0m"     # Reset color

# Display help message
show_help() {
    echo "Usage: $0 [-p repo_path] [-b branch_name] [-n num_commits] [-h]"
    echo "  -p repo_path      Git repository path (overrides $DETAILS_FILE)"
    echo "  -b branch_name    Branch to reset (default: current branch)"
    echo "  -n num_commits    Number of commits to reset (default: 1), can be a range (e.g., 1-3)"
    echo "  -h                Show this help message"
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

# Log repository path and branch name in dark pink
log_repo_info() {
    echo -e "${COLOR_MAIN}REPO PATH:${COLOR_RESET} $1"  # Dark pink text for repo path
    echo -e "${COLOR_MAIN}BRANCH NAME:${COLOR_RESET} $2"  # Dark pink text for branch name
}

# Check if Git is installed
check_git_installed() {
    command -v git &> /dev/null || log_error "Git is not installed. Install Git and try again."
}

# Read repository path from repo_details.txt
read_details_file() {
    if [[ ! -f "$DETAILS_FILE" ]]; then
        log_error "$DETAILS_FILE not found! Provide details via -p or create $DETAILS_FILE."
    fi
    repo_path_file=$(awk 'NR==1 {print $0}' "$DETAILS_FILE" | xargs)  # Get first line as repo path
}

# Convert Windows-style path to Unix-style path for Git Bash
convert_path() {
    local path="$1"
    [[ "$path" =~ ^([A-Z]): ]] && path="/${BASH_REMATCH[1],,}/$(echo "$path" | sed 's|\\|/|g' | sed 's|^[A-Z]:||')"
    echo "$path"
}

# Parse the commit range and calculate the number of commits to reset
parse_commit_range() {
    local range="$1"
    if [[ "$range" =~ ^([0-9]+)(-([0-9]+))?$ ]]; then
        start=${BASH_REMATCH[1]}
        end=${BASH_REMATCH[3]:-$start}  # If no end is provided, use start as end
        num_commits=$((end - start + 1))
        if (( start > end )); then
            log_error "Invalid range: $range. Start must be less than or equal to end."
        fi
        echo "$num_commits"
    else
        log_error "Invalid commit range format: $range. Use 'N' or 'N-M'."
    fi
}

# Main logic
main() {
    local repo_path=""
    local branch_name=""
    local num_commits=1  # Default to 1 commit

    # Parse command-line options
    while getopts ":p:b:n:h" opt; do
        case "$opt" in
            p) repo_path=$(convert_path "$OPTARG") ;;  # Convert and set repository path
            b) branch_name="$OPTARG" ;;                   # Set branch name
            n) num_commits=$(parse_commit_range "$OPTARG") ;;  # Set number of commits to reset
            h) show_help ;;                                # Show help message
            *) log_error "Invalid option: -$OPTARG"; exit 2 ;;  # Handle invalid options
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

    log_info "Navigating to repository: $repo_path"

    # Change to the repository directory and run git reset and push
    (
        cd "$repo_path" || log_error "Failed to access directory: $repo_path"

        # If branch name is not provided, use the current branch
        if [[ -z "$branch_name" ]]; then
            branch_name=$(git rev-parse --abbrev-ref HEAD)
        fi
        
        # Log the branch name and repository path in dark pink
        log_repo_info "$repo_path" "$branch_name"
        
        log_info "Resetting the last $num_commits commit(s) on branch '$branch_name'"
        git reset --hard HEAD~"$num_commits" || log_error "Git reset failed!"

        log_info "Force pushing changes to branch '$branch_name'"
        git push -f origin "$branch_name" || log_error "Git push failed!"

        log_info "Repository state after operation:"
        git status
    )
}

# Execute main function
main "$@"
