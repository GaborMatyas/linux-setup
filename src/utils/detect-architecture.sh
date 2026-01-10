#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   detect_architecture <format>
#
# Formats:
#   fzf       - Returns platform string for fzf releases
#   ripgrep   - Returns platform string for ripgrep releases
#   fd        - Returns platform string for fd releases
#
# Behavior:
# - Detects system architecture using uname -m
# - Converts to appropriate platform string for the specified format
# - Exits with error if architecture is unsupported for that format
#
# Examples:
#   PLATFORM="$(detect_architecture fzf)"
#   PLATFORM="$(detect_architecture ripgrep)"

detect_architecture() {
  local format="$1"
  local arch
  arch="$(uname -m)"

  case "${format}" in
    fzf)
      case "${arch}" in
        x86_64)   echo "linux_amd64" ;;
        aarch64)  echo "linux_arm64" ;;
        armv7l)   echo "linux_armv7" ;;
        *)
          echo "ERROR: Unsupported architecture for fzf: ${arch}" >&2
          echo "Supported: x86_64, aarch64, armv7l" >&2
          return 1
          ;;
      esac
      ;;
    ripgrep)
      case "${arch}" in
        x86_64)   echo "x86_64-unknown-linux-musl" ;;
        aarch64)  echo "aarch64-unknown-linux-gnu" ;;
        *)
          echo "ERROR: Unsupported architecture for ripgrep: ${arch}" >&2
          echo "Supported: x86_64, aarch64" >&2
          return 1
          ;;
      esac
      ;;
    fd)
      case "${arch}" in
        x86_64)   echo "x86_64-unknown-linux-gnu" ;;
        aarch64)  echo "aarch64-unknown-linux-gnu" ;;
        *)
          echo "ERROR: Unsupported architecture for fd: ${arch}" >&2
          echo "Supported: x86_64, aarch64" >&2
          return 1
          ;;
      esac
      ;;
    *)
      echo "ERROR: Unknown format: ${format}" >&2
      echo "Supported formats: fzf, ripgrep, fd" >&2
      return 1
      ;;
  esac
}

# If executed as a script (not sourced), run as CLI:
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <format>" >&2
    echo "Formats: fzf, ripgrep, fd" >&2
    exit 1
  fi
  detect_architecture "$@"
fi
