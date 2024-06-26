#!/bin/bash
: '
Author: Ajay Singh
Version: 1.0
date: 20-05-2025
'
echo "Adding All files..."
git add .

echo "Committing..."
commit_message=$(<commitM.txt)
baseline_message=$(<baseline.txt)

git commit -m "$commit_message$baseline_message"

echo "Pushing into the branch..."
git push

echo "Updating Status..."
git status