#!/bin/bash
# Author: Ajay Singh
# Version: 1.1
# Date: 20-05-2024

# Read the repository path from a file (e.g., repo_path.txt)
if [ ! -f "repo_path.txt" ]; then
    echo "Error: repo_path.txt not found!"
    exit 1
fi

repo_path=$(<repo_path.txt)

# Ensure the commit message file exists and is readable before changing directory
if [ ! -f "commitM.txt" ]; then
    echo "Error: commitM.txt not found!"
    exit 1
fi

# Read commit message, trim newlines or extra spaces before changing directory
echo "Reading commit message..."
commit_message=$(<commitM.txt)
commit_message=$(echo "$commit_message" | tr -d '\n\r')

# Check if the commit message is empty after trimming
if [ -z "$commit_message" ]; then
    echo "Error: Commit message is empty!"
    exit 1
fi

# Now, check if the repo path exists and change directory
if [ -d "$repo_path" ]; then
    echo "Navigating to the repository folder: $repo_path"
    cd "$repo_path" || exit
else
    echo "Error: Repository path not found: $repo_path"
    exit 1
fi

echo "Adding all files..."
git add .

# Prepare the commit message with the baseline
baseline_message="_baseline"

# Output final commit command
echo "Executing git commit -m '$commit_message $baseline_message'"
git commit -m "$commit_message $baseline_message"

echo "Pushing into the branch..."
# Specify the branch to push to (replace 'main' with the actual branch if needed)
git push origin main

echo "Updating status..."
git status
