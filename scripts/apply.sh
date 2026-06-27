#!/usr/bin/env bash
# Apply this repo's Ghostty config to the local system, choosing a lazer color.
# Usage: ./scripts/apply.sh [red|blue|lightning]   (default: blue)
#
# Backs up the current live config first, then copies the repo config and the
# chosen color variant into place (as shaders/cursor_blaze.glsl).
# Reload in Ghostty with ⌘+Shift+, — no restart needed.
set -euo pipefail

COLOR="${1:-blue}"
case "$COLOR" in
  red|blue|lightning) ;;
  *) echo "Unknown color '$COLOR'. Use: red | blue | lightning" >&2; exit 1 ;;
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

# Auto-reload: Ghostty reloads its config on SIGUSR2 — no keystroke needed.
# Find the running GUI process (pgrep first, ps fallback for sandboxed shells).
PIDS="$(pgrep -x ghostty 2>/dev/null || true)"
if [[ -z "$PIDS" ]]; then
  PIDS="$(ps -Ao pid,comm | awk '/Ghostty\.app\/Contents\/MacOS\/ghostty$/{print $1}')"
fi

if [[ -n "$PIDS" ]]; then
  for pid in $PIDS; do kill -USR2 "$pid" 2>/dev/null || true; done
  echo "Reloaded Ghostty (SIGUSR2) — the $COLOR lazer is live."
else
  echo "Ghostty not running; it'll pick up the config on next launch."
fi
