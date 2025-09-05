
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

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1; then
  error_exit "Homebrew is not installed. Please install Homebrew first: https://brew.sh/"
fi

# Check for VS Code CLI
if ! command -v code >/dev/null 2>&1; then
  error_exit "VS Code CLI ('code') is not installed or not in PATH. Launch VS Code, open Command Palette, and run 'Shell Command: Install 'code' command in PATH'."
fi

# Install Homebrew apps from apps.txt
if [[ -f apps.txt ]]; then
  if [[ -s apps.txt ]]; then
    echo "[INFO] Installing Homebrew apps from apps.txt..."
    if ! xargs brew install < apps.txt; then
      error_exit "Failed to install one or more Homebrew apps. Check apps.txt and Homebrew logs."
    fi
  else
    echo "[INFO] apps.txt is empty. No Homebrew apps to install."
  fi
else
  error_exit "apps.txt file not found! Please create apps.txt with a list of Homebrew apps."
fi

# Install VS Code extensions from vs-code-extensions.txt
if [[ -f vs-code-extensions.txt ]]; then
  if [[ -s vs-code-extensions.txt ]]; then
    echo "[INFO] Installing VS Code extensions from vs-code-extensions.txt..."
    # Install each extension and report failures
    while IFS= read -r ext || [[ -n "$ext" ]]; do
      if [[ -n "$ext" ]]; then
        echo "[INFO] Installing VS Code extension: $ext"
        if ! code --install-extension "$ext"; then
          echo "[WARNING] Failed to install VS Code extension: $ext" >&2
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
