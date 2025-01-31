#!/bin/bash

# Check if the number of arguments is correct
if [[ $# != 2 ]]; then
  echo "Usage: backup.sh target_directory_name destination_directory_name"
  exit 1
fi

# Check if the arguments are valid directory paths
if [[ ! -d $1 ]] || [[ ! -d $2 ]]; then
  echo "Invalid directory path provided"
  exit 1
fi

# Set two variables equal to the values of the first and second command line arguments
targetDirectory=$1
destinationDirectory=$2

# Display the values of the two command line arguments
echo "Target directory: $targetDirectory"
echo "Destination directory: $destinationDirectory"

# Get the current timestamp
currentTS=$(date +%s)

# Define the backup file name using the current timestamp
backupFileName="backup-$currentTS.tar.gz"

# Save the original absolute path
origAbsPath=$(pwd)

# Change to the destination directory and get its absolute path
cd "$destinationDirectory" || { echo "Failed to change to destination directory"; exit 1; }
destAbsPath=$(pwd)

# Change to the target directory
cd "$origAbsPath"
cd "$targetDirectory" || { echo "Failed to change to target directory"; exit 1; }

# Calculate the timestamp for 24 hours ago
yesterdayTS=$((currentTS - 86400))

# Find files modified in the last 24 hours
declare -a toBackup

for file in $(ls); do
  if [[ -f "$file" && $(date -r "$file" +%s) -gt $yesterdayTS ]]; then
    toBackup+=("$file")
  fi
done

# Check if there are files to back up
if [[ ${#toBackup[@]} -eq 0 ]]; then
  echo "No files to back up."
  exit 0
fi

# Compress and archive the files into the backup file
tar -czvf "$backupFileName" "${toBackup[@]}"

# Move the backup file to the destination directory
mv "$backupFileName" "$destAbsPath" || { echo "Failed to move $backupFileName to $destAbsPath"; exit 1; }

echo "Backup completed successfully. File: $destAbsPath/$backupFileName"
