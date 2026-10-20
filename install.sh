#!/bin/bash

# allow specifying different destination directory
DIR="${DIR:-"$HOME/.local/bin"}"

# map different architecture variations to the available binaries
ARCH=$(uname -m)
case $ARCH in
    i386|i686) ARCH=x86_64 ;;
    aarch64*|arm64) ARCH=aarch64 ;;
esac

# prepare the download URL
# Resolve the tag from the release redirect URL to avoid GitHub API rate limits
GITHUB_LATEST_VERSION=$(curl -fsSL -o /dev/null -w "%{url_effective}" https://github.com/rgwood/systemctl-tui/releases/latest | sed 's|.*/tag/||')

# Fallback to GitHub API if redirect resolution does not yield a tag
if [ -z "$GITHUB_LATEST_VERSION" ] || [ "$GITHUB_LATEST_VERSION" = "latest" ]; then
    GITHUB_LATEST_VERSION=$(curl -sL https://api.github.com/repos/rgwood/systemctl-tui/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
fi
GITHUB_FILE="systemctl-tui-${ARCH}-unknown-linux-musl.tar.gz"
GITHUB_URL="https://github.com/rgwood/systemctl-tui/releases/download/${GITHUB_LATEST_VERSION}/${GITHUB_FILE}"

# install/update the local binary

# check curl downloads bin correctly
if ! curl -L -f -o systemctl-tui.tar.gz "$GITHUB_URL"; then
    echo "The requested file '$GITHUB_FILE' for version '$GITHUB_LATEST_VERSION' and architecture '$ARCH' may not exist." >&2
    exit 1
fi

tar xzvf systemctl-tui.tar.gz systemctl-tui
install -Dm 755 systemctl-tui -t "$DIR"
rm systemctl-tui systemctl-tui.tar.gz
