#!/bin/bash

# Script to download quickmark-server binaries from GitHub releases
# Reads version from package.json and downloads platform-specific binaries

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BIN_DIR="$PROJECT_ROOT/bin"
PACKAGE_JSON="$PROJECT_ROOT/package.json"

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are available
check_dependencies() {
    local missing=()

    if ! command -v jq >/dev/null 2>&1; then
        missing+=(jq)
    fi

    if ! command -v curl >/dev/null 2>&1; then
        missing+=(curl)
    fi

    if ! command -v tar >/dev/null 2>&1; then
        missing+=(tar)
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing[*]}"
        print_error "Please install them and try again."
        exit 1
    fi
}

# Extract version from package.json
get_version() {
    if [ ! -f "$PACKAGE_JSON" ]; then
        print_error "package.json not found at $PACKAGE_JSON"
        exit 1
    fi

    local version
    version=$(jq -r '.quickmarkServer.version // empty' "$PACKAGE_JSON")

    if [ -z "$version" ] || [ "$version" = "null" ]; then
        print_error "quickmarkServer.version not found in package.json"
        exit 1
    fi

    echo "$version"
}

# Download and extract binary for a specific platform
download_binary() {
    local platform=$1
    local version=$2
    local base_url="https://github.com/ekropotin/quickmark/releases/download/quickmark-server%40${version}"
    local binary_name="quickmark-server-${platform}"

    # All assets are tar.gz files
    local archive_name="quickmark-server-${platform}.tar.gz"

    local download_url="${base_url}/${archive_name}"
    local temp_file="/tmp/${archive_name}"

    print_info "Downloading $binary_name..."
    print_info "URL: $download_url"

    # Download with curl
    if ! curl -L -o "$temp_file" "$download_url"; then
        print_error "Failed to download $download_url"
        return 1
    fi

    # Check if we actually got a valid file (not a 404 page)
    local file_size=$(stat -f%z "$temp_file" 2>/dev/null || stat -c%s "$temp_file" 2>/dev/null || echo "0")
    if [ "$file_size" -lt 100 ]; then
        print_error "Downloaded file is too small ($file_size bytes), likely a 404 error"
        print_error "URL: $download_url"
        rm -f "$temp_file"
        return 1
    fi

    # Extract the binary
    print_info "Extracting $binary_name..."
    if ! tar -xzf "$temp_file" -C /tmp; then
        print_error "Failed to extract $temp_file"
        rm -f "$temp_file"
        return 1
    fi

    # Find the extracted binary
    local extracted_binary="/tmp/quickmark-server"
    if [[ "$platform" == *"windows"* ]]; then
        extracted_binary="/tmp/quickmark-server.exe"
    fi

    if [ ! -f "$extracted_binary" ]; then
        print_error "Could not find extracted binary: $extracted_binary"
        print_error "Available files in /tmp:"
        ls -la /tmp/quickmark* 2>/dev/null || true
        rm -f "$temp_file"
        return 1
    fi

    # Move to bin directory with correct name (preserve .exe for Windows)
    local target_path="$BIN_DIR/$binary_name"
    if [[ "$platform" == *"windows"* ]] && [[ "$extracted_binary" == *.exe ]]; then
        target_path="${target_path}.exe"
    fi

    mv "$extracted_binary" "$target_path"
    chmod +x "$target_path"

    # Clean up
    rm -f "$temp_file"

    print_info "Successfully downloaded and installed $binary_name"
    return 0
}

# Main function
main() {
    print_info "Starting quickmark-server binary download..."

    # Check dependencies
    check_dependencies

    # Get version from package.json
    local version
    version=$(get_version)
    print_info "Found quickmarkServer version: $version"

    # Define platforms to download
    local platforms=(
        "x86_64-apple-darwin"
        "aarch64-apple-darwin"
        "x86_64-unknown-linux-gnu"
        "aarch64-unknown-linux-gnu"
        "x86_64-pc-windows-msvc"
    )

    local success_count=0
    local total_count=${#platforms[@]}

    # Download binaries for each platform
    for platform in "${platforms[@]}"; do
        if download_binary "$platform" "$version"; then
            ((success_count++))
        else
            print_warn "Failed to download binary for $platform"
        fi
    done

    print_info "Download complete: $success_count/$total_count binaries downloaded successfully"

    if [ $success_count -eq 0 ]; then
        print_error "No binaries were downloaded successfully"
        exit 1
    elif [ $success_count -lt $total_count ]; then
        print_warn "Some binaries failed to download"
        exit 2
    else
        print_info "All binaries downloaded successfully!"
    fi
}

# Run main function
main "$@"
