# Git Repository Management Scripts

This repository contains a set of Bash scripts designed for managing Git repositories. Each script performs specific tasks related to Git operations.

## Scripts Overview

- **`s.sh`**: Displays the status of a Git repository.
- **`check.sh`**: Checks out a specified branch in the repository.
- **`base.sh`**: Commits and pushes changes to the repository.
- **`config.sh`**: Similar to `base.sh` but modifies the commit message.
- **`reset.sh`**: Resets a specified number of commits on a branch.

## How to Setup

1. **Prerequisites**: Ensure Git is installed on your system.
2. **File Creation**:
   - Create a file named `repo_details.txt` containing the repository path (first line) and branch name (second line).
   - For `base.sh` and `config.sh`, create a file named `commit_message.txt` for commit messages.
3. **Make Scripts Executable**: Run the following command for each script:
   ```bash
   chmod +x <script_name>.sh
