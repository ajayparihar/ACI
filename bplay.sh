#!/bin/bash
: '
Author: Ajay Singh
Version: 1.0
date: 20-05-2025
'

echo "Commit"
commit_message=$(<commitM.txt)
baseline_message=$(<baseline.txt)

git commit -m "$commit_message$baseline_message"


