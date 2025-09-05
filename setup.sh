#!/usr/bin/env bash
set -euo pipefail

# Helper function for consistent messaging
print_message() {
  local type="$1"
  local message="$2"
  case "$type" in
    "info")
      echo "ℹ️  $message"
      ;;
    "success")
      echo "✅ $message"
      ;;
    "warning")
      echo "⚠️  $message" >&2
      ;;
    "error")
      echo "❌ $message" >&2
      ;;
  esac
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  print_message "error" "Homebrew is not installed. Please install Homebrew first:"
  print_message "info" "Visit https://brew.sh/ for installation instructions"
  exit 1
fi

# Check if VS Code CLI is installed
if ! command -v code &> /dev/null; then
  print_message "error" "VS Code CLI is not available. Please install VS Code and enable shell commands:"
  print_message "info" "Open VS Code → Command Palette (Cmd+Shift+P) → 'Shell Command: Install code command in PATH'"
  exit 1
fi

print_message "success" "Prerequisites check passed - Homebrew and VS Code CLI are available"

# Install Homebrew apps from apps.txt
if [[ -f apps.txt ]]; then
  # Check if file is empty or contains only whitespace
  if [[ ! -s apps.txt ]] || ! grep -q '[^[:space:]]' apps.txt; then
    print_message "info" "apps.txt is empty - skipping Homebrew app installation"
  else
    print_message "info" "Installing Homebrew apps from apps.txt..."
    if xargs brew install < apps.txt; then
      print_message "success" "Homebrew apps installation completed"
    else
      print_message "error" "Failed to install some Homebrew apps"
      exit 1
    fi
  fi
else
  print_message "error" "apps.txt file not found!"
  exit 1
fi

# Install VS Code extensions from vs-code-extensions.txt
if [[ -f vs-code-extensions.txt ]]; then
  # Check if file is empty or contains only whitespace
  if [[ ! -s vs-code-extensions.txt ]] || ! grep -q '[^[:space:]]' vs-code-extensions.txt; then
    print_message "info" "vs-code-extensions.txt is empty - skipping VS Code extensions installation"
  else
    print_message "info" "Installing VS Code extensions from vs-code-extensions.txt..."
    
    # Install extensions one by one to handle individual failures
    failed_extensions=()
    while IFS= read -r extension; do
      # Skip empty lines and lines with only whitespace
      if [[ -n "${extension// }" ]]; then
        if code --install-extension "$extension" &> /dev/null; then
          print_message "success" "Installed extension: $extension"
        else
          print_message "warning" "Failed to install extension: $extension"
          failed_extensions+=("$extension")
        fi
      fi
    done < vs-code-extensions.txt
    
    # Report summary of extension installation
    if [[ ${#failed_extensions[@]} -eq 0 ]]; then
      print_message "success" "All VS Code extensions installed successfully"
    else
      print_message "warning" "Failed to install ${#failed_extensions[@]} extension(s): ${failed_extensions[*]}"
    fi
  fi
else
  print_message "error" "vs-code-extensions.txt file not found!"
  exit 1
fi

print_message "success" "Setup complete!"
