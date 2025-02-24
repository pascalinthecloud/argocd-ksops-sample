#!/bin/bash

# Ensure that the action (import/encrypt/decrypt) and path are provided
if [ -z "$1" ]; then
  echo "Usage: $0 <import|encrypt|decrypt> <path> [key_file (for import)]"
  exit 1
fi

# Action: import, encrypt, or decrypt
action=$1

# Get the directory of the script
script_dir=$(dirname "$(realpath "$0")")

# Handle the 'import' action
if [ "$action" == "import" ]; then
  # Ensure that the key file is provided
  if [ -z "$2" ]; then
    echo "Usage: $0 import <key_file>"
    exit 1
  fi

  key_file=$2

  # Check if the key file exists
  if [ ! -f "$key_file" ]; then
    echo "Key file $key_file does not exist."
    exit 1
  fi

  # Import the GPG private key
  echo "Importing the private key from $key_file..."
  gpg --import "$key_file"
  if [ $? -ne 0 ]; then
    echo "Failed to import the GPG private key."
    exit 1
  fi

  echo "Private key imported successfully."
  exit 0
fi

# Ensure that the path is provided for encrypt/decrypt
if [ -z "$2" ]; then
  echo "Usage: $0 <encrypt|decrypt> <path>"
  exit 1
fi

# Path provided by the user
directory=$2

# Check if the provided directory exists
if [ ! -d "$directory" ]; then
  echo "Directory $directory does not exist."
  exit 1
fi

# Perform the action on all .yaml files in the specified directory
for file in "$directory"/*.yaml; do
  if [ -f "$file" ]; then
    if [ "$action" == "encrypt" ]; then
      echo "Encrypting $file..."
      sops --encrypt --in-place "$file"
    elif [ "$action" == "decrypt" ]; then
      echo "Decrypting $file..."
      sops --decrypt --in-place "$file"
    else
      echo "Invalid action. Use 'encrypt' or 'decrypt'."
      exit 1
    fi
  else
    echo "No .yaml files found in the specified directory."
    exit 1
  fi
done
