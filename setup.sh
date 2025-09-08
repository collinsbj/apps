#!/usr/bin/env bash
set -euo pipefail

# --- Setup Script for macOS Development Environment ---
# This script installs Homebrew apps and VS Code extensions listed in apps.txt and vs-code-extensions.txt.
# It provides robust error handling, clear messages, and checks for required dependencies.

# Helper function for error messages
error_exit() {
  echo "[ERROR] $1" >&2
  exit 1
}

# Arrays to track failed installations
failed_apps=()
failed_extensions=()

# Check for Homebrew
# This checks if the 'brew' command is available in the system PATH
if ! command -v brew >/dev/null 2>&1; then
  error_exit "Homebrew is not installed. Please install Homebrew first: https://brew.sh/"
fi

# Check for VS Code CLI
# This checks if the 'code' command is available in the system PATH
if ! command -v code >/dev/null 2>&1; then
  error_exit "VS Code CLI ('code') is not installed or not in PATH. Launch VS Code, open Command Palette, and run 'Shell Command: Install 'code' command in PATH'."
fi

# Install Homebrew apps from apps.txt
# This checks if the apps.txt file exists in the current directory
if [[ -f apps.txt ]]; then
  # This checks if apps.txt has content (is not empty)
  if [[ -s apps.txt ]]; then
    echo "[INFO] Installing Homebrew apps from apps.txt..."
    # Install each app individually and report failures
    while IFS= read -r app || [[ -n "$app" ]]; do
      # Trim whitespace first
      app=$(echo "$app" | xargs)
      # This checks if the line is not empty and does not start with a '#' comment
      if [[ -n "$app" && ! "$app" =~ ^# ]]; then
        echo "[INFO] Installing Homebrew app: $app"
        # This checks if the brew install command failed
        if ! brew install $app; then
          echo "[WARNING] Failed to install Homebrew app: $app" >&2
          failed_apps+=("$app")
        fi
      fi
    done < apps.txt
  else
    echo "[INFO] apps.txt is empty. No Homebrew apps to install."
  fi
else
  error_exit "apps.txt file not found! Please create apps.txt with a list of Homebrew apps."
fi

# Install VS Code extensions from vs-code-extensions.txt
# This checks if the vs-code-extensions.txt file exists in the current directory
if [[ -f vs-code-extensions.txt ]]; then
  # This checks if vs-code-extensions.txt has content (is not empty)
  if [[ -s vs-code-extensions.txt ]]; then
    echo "[INFO] Installing VS Code extensions from vs-code-extensions.txt..."
    # Install each extension and report failures
    while IFS= read -r ext || [[ -n "$ext" ]]; do
      # Trim whitespace first
      ext=$(echo "$ext" | xargs)
      # This checks if the line is not empty and does not start with a '#' comment
      if [[ -n "$ext" && ! "$ext" =~ ^# ]]; then
        echo "[INFO] Installing VS Code extension: $ext"
        # This checks if the extension install command failed
        if ! code --install-extension "$ext"; then
          echo "[WARNING] Failed to install VS Code extension: $ext" >&2
          failed_extensions+=("$ext")
        fi
      fi
    done < vs-code-extensions.txt
  else
    echo "[INFO] vs-code-extensions.txt is empty. No VS Code extensions to install."
  fi
else
  error_exit "vs-code-extensions.txt file not found! Please create vs-code-extensions.txt with a list of extension IDs."
fi

echo "[SUCCESS] Setup complete!"

# Display summary of failed installations if any
if [[ ${#failed_apps[@]} -gt 0 ]] || [[ ${#failed_extensions[@]} -gt 0 ]]; then
  echo ""
  echo "[SUMMARY] Some installations failed:"
  
  if [[ ${#failed_apps[@]} -gt 0 ]]; then
    echo ""
    echo "Failed Homebrew apps:"
    for app in "${failed_apps[@]}"; do
      echo "  - $app"
    done
  fi
  
  if [[ ${#failed_extensions[@]} -gt 0 ]]; then
    echo ""
    echo "Failed VS Code extensions:"
    for ext in "${failed_extensions[@]}"; do
      echo "  - $ext"
    done
  fi
  
  echo ""
  echo "[INFO] You can manually retry installing the failed items later."
else
  echo "[INFO] All installations completed successfully!"
fi
