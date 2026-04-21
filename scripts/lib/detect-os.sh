#!/usr/bin/env bash
# OS detection helper. Echoes one of: macos | linux | wsl | unsupported
# Usage: OS="$(bash scripts/lib/detect-os.sh)"

kernel="$(uname -s 2>/dev/null || echo unknown)"
case "$kernel" in
  Darwin) echo macos ;;
  Linux)
    if grep -qi 'microsoft' /proc/version 2>/dev/null; then
      echo wsl
    else
      echo linux
    fi
    ;;
  *) echo unsupported ;;
esac
