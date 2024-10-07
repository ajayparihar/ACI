#!/bin/bash
: '
Author: Ajay Singh
Version: 1.1
date: 20-05-2024
'

# Read the repository path from a file (e.g., repo_path.txt)
repo_path=$(<repo_path.txt)

# Check if the repo path exists and change directory
if [ -d "$repo_path" ]; then
    echo "Navigating to the repository folder: $repo_path"
    cd "$repo_path" || exit
else
    echo "Repository path not found: $repo_path"
    exit 1
fi

echo "Adding all files..."
git add .

echo "Committing..."
commit_message=$(<commitMessage.txt)
config_message="config"

git commit -m "$commit_message $config_message"

echo "Pushing into the branch..."
git push

echo "Updating status..."
git status
