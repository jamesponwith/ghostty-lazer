#!/usr/bin/env bash
# Apply this repo's Ghostty config to the local system, choosing a lazer color.
# Usage: ./scripts/apply.sh [red|blue]   (default: blue)
#
# Backs up the current live config first, then copies the repo config and the
# chosen color variant into place (as shaders/cursor_blaze.glsl).
# Reload in Ghostty with ⌘+Shift+, — no restart needed.
set -euo pipefail

COLOR="${1:-blue}"
case "$COLOR" in
  red|blue) ;;
  *) echo "Unknown color '$COLOR'. Use: red | blue" >&2; exit 1 ;;
esac

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$REPO_ROOT/ghostty"
VARIANT="$SRC_DIR/shaders/cursor_blaze_${COLOR}.glsl"
DEST="${GHOSTTY_CONFIG_DIR:-$HOME/.config/ghostty}"

if [[ ! -f "$VARIANT" ]]; then
  echo "Missing shader variant: $VARIANT" >&2
  exit 1
fi

# Back up whatever is currently installed before we overwrite it.
"$REPO_ROOT/scripts/backup.sh"

mkdir -p "$DEST/shaders"
cp "$SRC_DIR/config" "$DEST/config"
cp "$VARIANT" "$DEST/shaders/cursor_blaze.glsl"

echo "Applied '$COLOR' lazer to $DEST"
echo "Reload Ghostty with ⌘+Shift+, to see it."
