#!/usr/bin/env bash
# Apply this repo's Ghostty config to the local system, choosing a lazer color.
# Usage: ./scripts/apply.sh [red|blue|yellow|lightning] [tint] [AMP_ARC]   (default: blue, straight beam)
# AMP_ARC bends the trail: forward jumps arc up, backward jumps arc down.
# lightning takes an optional tint (red|blue|yellow) to recolor the bolt,
# e.g. ./scripts/apply.sh lightning yellow AMP_ARC
#
# Backs up the current live config first, then copies the repo config and the
# chosen color variant into place (as shaders/cursor_blaze.glsl).
# Reload in Ghostty with ⌘+Shift+, — no restart needed.
set -euo pipefail

COLOR="${1:-blue}"
case "$COLOR" in
  red|blue|yellow|lightning) ;;
  *) echo "Unknown color '$COLOR'. Use: red | blue | yellow | lightning" >&2; exit 1 ;;
esac

TINT=""
MODE=""
for arg in "${@:2}"; do
  case "$arg" in
    red|blue|yellow) TINT="$arg" ;;
    AMP_ARC) MODE="AMP_ARC" ;;
    *) echo "Unknown option '$arg'. Use: red | blue | yellow (tint) | AMP_ARC" >&2; exit 1 ;;
  esac
done
if [[ -n "$TINT" && "$COLOR" != "lightning" ]]; then
  echo "A tint only applies to lightning (the beam variants are already colors)." >&2
  exit 1
fi

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

# ponytail: sed the installed copy instead of keeping a shape x color file matrix
if [[ "$MODE" == "AMP_ARC" ]]; then
  sed -i '' 's/^const bool ARC = false;/const bool ARC = true;/' "$DEST/shaders/cursor_blaze.glsl"
fi

# Tint: reuse the color consts from the matching beam shader.
if [[ -n "$TINT" ]]; then
  for c in TRAIL_COLOR TRAIL_COLOR_ACCENT; do
    line="$(grep "^const vec4 $c = " "$SRC_DIR/shaders/cursor_blaze_${TINT}.glsl")"
    sed -i '' "s|^const vec4 $c = .*|$line|" "$DEST/shaders/cursor_blaze.glsl"
  done
fi

echo "Applied '$COLOR' lazer${TINT:+ ($TINT tint)}${MODE:+ ($MODE)} to $DEST"

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
