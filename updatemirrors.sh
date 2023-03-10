#!/bin/bash

# Default number of mirrors to include in the list
DEFAULT_NUM_MIRRORS=20

# Define the default location of your mirror list file
MIRROR_LIST_FILE="/etc/pacman.d/mirrorlist"

# Define the backup directory where you want to store the old mirror list file
BACKUP_DIR="$HOME/mirrorlist_backup"

# Define a function to display help information
function show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "OPTIONS:"
  echo "  -m, --mirror FILE    Path to mirror list file (default: $MIRROR_LIST_FILE)"
  echo "  -n, --number NUMBER  Number of mirrors to include in the list (default: $DEFAULT_NUM_MIRRORS)"
  echo "  -c, --country CODE   Filter mirrors by two-letter country code (e.g., US, GB, CN)"
  echo "  -h, --help           Show help information"
  exit 0
}

# Check if running with root privileges
if [[ $EUID -eq 0 ]]; then
  echo "This script should not be run with sudo. Please run it without sudo and enter your password when prompted."
  exit 1
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -m|--mirror)
      MIRROR_LIST_FILE="$2"
      shift 2
      ;;
    -n|--number)
      NUM_MIRRORS="$2"
      shift 2
      ;;
    -c|--country)
      COUNTRY="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      ;;
    *)
      echo "Invalid option: $key"
      show_help
      ;;
  esac
done

# Set the number of mirrors to include in the list
if [[ -z "$NUM_MIRRORS" ]]; then
  NUM_MIRRORS=$DEFAULT_NUM_MIRRORS
fi

# Create the backup directory if it doesn't exist
sudo mkdir -p "$BACKUP_DIR"
echo "Create the backup directory if it doesn't exist: $BACKUP_DIR"

# Create a backup copy of the mirror list file with a timestamp
BACKUP_FILE="$BACKUP_DIR/mirrorlist_$(date +%Y-%m-%d_%H-%M-%S)"
sudo cp "$MIRROR_LIST_FILE" "$BACKUP_FILE"
echo "Created backup of mirror list file: $BACKUP_FILE"

# Use Reflector to generate a new mirror list and save it to the original file location
echo "Updating mirror list with fastest available mirrors..."
if [[ -n "$COUNTRY" ]]; then
  sudo reflector --latest $NUM_MIRRORS --sort rate --country "$COUNTRY" --save "$MIRROR_LIST_FILE"
else
  sudo reflector --latest $NUM_MIRRORS --sort rate --save "$MIRROR_LIST_FILE"
fi

# Confirm that the new mirror list has been generated and saved successfully
echo "Mirror list updated successfully!"
