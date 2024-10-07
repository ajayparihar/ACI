```markdown
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
   ```

## How to Use

Each script can be executed with specific command-line options. Use the `-h` option to display help messages for each script.

### Script 1: `s.sh`

#### Usage
```bash
./s.sh -p <repository_path>
```
- To use the default path from `repo_details.txt`:
```bash
./s.sh
```
- To see the help message:
```bash
./s.sh -h
```

#### Functionality
- Checks if Git is installed.
- Reads the repository path from `repo_details.txt` or accepts it as a command-line argument.
- Navigates to the specified Git repository and runs `git status`.

#### Error Handling
- Displays an error message if Git is not installed.
- Checks if the `repo_details.txt` file exists and reads from it.
- Validates the existence of the specified repository path.

---

### Script 2: `check.sh`

#### Usage
```bash
./check.sh -b <branch_name>
```
- To specify a repository path:
```bash
./check.sh -p <repository_path> -b <branch_name>
```
- To see the help message:
```bash
./check.sh -h
```

#### Functionality
- Validates if Git is installed.
- Reads repository details from `repo_details.txt` or command-line arguments.
- Changes to the specified repository directory and checks out the specified branch.

#### Error Handling
- Displays an error if Git is not installed.
- Checks for the existence of `repo_details.txt`.
- Verifies that the specified branch exists before checking it out.

---

### Script 3: `base.sh`

#### Usage
```bash
./base.sh -m "<commit_message>"
```
- To use the commit message from `commit_message.txt`:
```bash
./base.sh
```
- To see the help message:
```bash
./base.sh -h
```

#### Functionality
- Checks if Git is installed.
- Reads repository details and commit messages from respective text files or command-line arguments.
- Adds all files to the Git index, commits them, and pushes to the specified branch.

#### Error Handling
- Handles missing files for repository details or commit messages.
- Validates the repository path and checks for successful Git operations.

---

### Script 4: `config.sh`

#### Usage
```bash
./config.sh -m "<commit_message>"
```
- To use the default message from `commit_message.txt`:
```bash
./config.sh
```
- To see the help message:
```bash
./config.sh -h
```

#### Functionality
- Similar to `base.sh` but appends `_config` to the commit message.
- Allows users to commit changes and push to the specified branch.

#### Error Handling
- Handles missing files and invalid Git operations.
- Displays error messages for common issues.

---

### Script 5: `reset.sh`

#### Usage
```bash
./reset.sh -n <num_commits>
```
- To specify the branch name and repository path:
```bash
./reset.sh -p <repository_path> -b <branch_name> -n <num_commits>
```
- To see the help message:
```bash
./reset.sh -h
```

#### Functionality
- Resets the specified number of commits on a given branch.
- Supports committing ranges.
- Forces the push to the remote repository after resetting.

#### Error Handling
- Checks for valid commit ranges and handles invalid inputs gracefully.
- Displays errors for Git installation and directory access issues.

---

## Additional Important Notes

- **Backup**: Always ensure you have backups of important data before running operations that modify commit history or repository states.
- **Testing**: It’s a good practice to test scripts in a safe environment (like a test repository) before using them on critical projects.
- **Permissions**: Make sure you have the necessary permissions to access and modify the repository and its files.
- **Logging**: Consider adding logging features to track actions performed by the scripts for future reference and debugging.

```