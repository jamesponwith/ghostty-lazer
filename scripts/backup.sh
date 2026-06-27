#!/usr/bin/env bash
# Back up the live Ghostty config to a timestamped folder for easy recovery.
# Usage: ./scripts/backup.sh
set -euo pipefail

SRC="${GHOSTTY_CONFIG_DIR:-$HOME/.config/ghostty}"
DEST_ROOT="$HOME/.config/ghostty-backups"

if [[ ! -d "$SRC" ]]; then
  echo "No Ghostty config found at $SRC — nothing to back up."
  exit 0
fi

TS="$(date +%Y%m%d-%H%M%S)"
DEST="$DEST_ROOT/$TS"
mkdir -p "$DEST"
cp -R "$SRC/." "$DEST/"

echo "Backed up $SRC -> $DEST"
