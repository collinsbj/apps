#!/usr/bin/env bash
# Enhanced setup script with robust error handling and user-friendly messaging
# This script installs Homebrew applications and VS Code extensions from configuration files

set -euo pipefail

# Helper function for consistent error messaging
error_message() {
    echo "❌ Error: $1" >&2
}

# Helper function for informational messages
info_message() {
    echo "ℹ️  Info: $1"
}

# Helper function for success messages
success_message() {
    echo "✅ $1"
}

# Helper function for warning messages
warning_message() {
    echo "⚠️  Warning: $1"
}

# Check if required dependencies are installed
check_dependencies() {
    info_message "Checking required dependencies..."
    
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        error_message "Homebrew is not installed or not in PATH."
        error_message "Please install Homebrew from https://brew.sh/ before running this script."
        exit 1
    fi
    success_message "Homebrew found"
    
    # Check for VS Code CLI
    if ! command -v code &> /dev/null; then
        error_message "VS Code CLI (code command) is not installed or not in PATH."
        error_message "Please install VS Code and ensure the 'code' command is available."
        error_message "You can install the CLI from VS Code: View > Command Palette > 'Shell Command: Install code command in PATH'"
        exit 1
    fi
    success_message "VS Code CLI found"
}

# Install Homebrew applications from apps.txt
install_homebrew_apps() {
    if [[ ! -f apps.txt ]]; then
        error_message "apps.txt file not found!"
        exit 1
    fi
    
    # Check if apps.txt is empty or contains only whitespace
    if [[ ! -s apps.txt ]] || [[ -z "$(grep -v '^[[:space:]]*$' apps.txt)" ]]; then
        info_message "apps.txt is empty - skipping Homebrew app installation"
        return 0
    fi
    
    info_message "Installing Homebrew apps from apps.txt..."
    
    # Install apps using brew, filtering out empty lines and comments
    if grep -v '^[[:space:]]*$\|^#' apps.txt | xargs brew install; then
        success_message "Homebrew apps installation completed"
    else
        error_message "Some Homebrew apps failed to install. Check the output above for details."
        exit 1
    fi
}

# Install VS Code extensions from vs-code-extensions.txt
install_vscode_extensions() {
    if [[ ! -f vs-code-extensions.txt ]]; then
        error_message "vs-code-extensions.txt file not found!"
        exit 1
    fi
    
    # Check if vs-code-extensions.txt is empty or contains only whitespace
    if [[ ! -s vs-code-extensions.txt ]] || [[ -z "$(grep -v '^[[:space:]]*$' vs-code-extensions.txt)" ]]; then
        info_message "vs-code-extensions.txt is empty - skipping VS Code extensions installation"
        return 0
    fi
    
    info_message "Installing VS Code extensions from vs-code-extensions.txt..."
    
    local failed_extensions=()
    local installed_count=0
    local total_count=0
    
    # Read extensions line by line, filtering out empty lines and comments
    while IFS= read -r extension; do
        # Skip empty lines and comments
        [[ -z "$extension" || "$extension" =~ ^[[:space:]]*$ || "$extension" =~ ^# ]] && continue
        
        total_count=$((total_count + 1))
        info_message "Installing extension: $extension"
        
        # Install extension individually to handle failures gracefully
        if code --install-extension "$extension" --force; then
            success_message "Successfully installed: $extension"
            installed_count=$((installed_count + 1))
        else
            warning_message "Failed to install extension: $extension"
            failed_extensions+=("$extension")
        fi
    done < vs-code-extensions.txt
    
    # Report installation summary
    if [[ $total_count -eq 0 ]]; then
        info_message "No valid extensions found in vs-code-extensions.txt"
    else
        success_message "VS Code extensions installation completed: $installed_count/$total_count installed successfully"
        
        if [[ ${#failed_extensions[@]} -gt 0 ]]; then
            warning_message "The following extensions failed to install:"
            for ext in "${failed_extensions[@]}"; do
                echo "  - $ext"
            done
            warning_message "You may want to install these manually or check if they are still available"
        fi
    fi
}

# Main execution flow
main() {
    echo "🚀 Starting development environment setup..."
    echo
    
    # Step 1: Check dependencies
    check_dependencies
    echo
    
    # Step 2: Install Homebrew apps
    install_homebrew_apps
    echo
    
    # Step 3: Install VS Code extensions
    install_vscode_extensions
    echo
    
    success_message "Setup complete! Your development environment is ready."
}

# Execute main function
main "$@"
