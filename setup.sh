#!/usr/bin/env bash
set -euo pipefail

# Install Homebrew apps from apps.txt
if [[ -f apps.txt ]]; then
  echo "Installing Homebrew apps from apps.txt..."
  xargs brew install < apps.txt
else
  echo "Error: apps.txt file not found!" >&2
  exit 1
fi

# Install VS Code extensions from vs-code-extensions.txt
if [[ -f vs-code-extensions.txt ]]; then
  echo "Installing VS Code extensions..."
  cat vs-code-extensions.txt | xargs -L1 code --install-extension
else
  echo "Error: vs-code-extensions.txt file not found!" >&2
  exit 1
fi

echo "Setup complete!"
