# ghostty-lazer

My [Ghostty](https://ghostty.org) terminal configuration, focused on the
**"lazer" cursor** — a custom GLSL shader that fires a glowing blaze trail when
the cursor jumps across the screen. Ships in two colors: **red** and **blue**.

## What's here

```
ghostty/
├── config                       # Ghostty config (wires up the shader)
└── shaders/
    ├── cursor_blaze_red.glsl    # red/amber lazer (the original)
    └── cursor_blaze_blue.glsl   # blue/cyan lazer
scripts/
├── apply.sh                     # push a chosen color to ~/.config/ghostty
└── backup.sh                    # back up the live config, timestamped
```

The config points at `shaders/cursor_blaze.glsl`; `apply.sh` generates that file
on the system by copying the chosen color variant into place.

## Apply / switch color

```sh
./scripts/apply.sh blue   # azure/cyan lazer  (default)
./scripts/apply.sh red    # red/amber lazer
```

Each run **backs up your current config first** (see Recovery), copies the repo
`config` into `~/.config/ghostty`, and installs the chosen variant as
`shaders/cursor_blaze.glsl`. Reload in-app with `⌘+Shift+,` — no restart needed.

## Backup & recovery

Backups live at `~/.config/ghostty-backups/<timestamp>/`. Make one anytime:

```sh
./scripts/backup.sh
```

Restore a backup by copying it back:

```sh
cp -R ~/.config/ghostty-backups/<timestamp>/. ~/.config/ghostty/
```

## Tuning the lazer

Edit the constants at the top of either `cursor_blaze_*.glsl`:

| Constant            | Effect                                              |
| ------------------- | --------------------------------------------------- |
| `TRAIL_COLOR`       | Core trail color (red: amber · blue: azure)         |
| `TRAIL_COLOR_ACCENT`| Leading-edge accent (red: red-orange · blue: cyan)  |
| `DURATION`          | How long the trail lingers (seconds)                |
| `OPACITY`           | Trail opacity                                       |
| `DRAW_THRESHOLD`    | Min jump distance (× cursor size) before a trail draws — stops trails while typing |

Shader adapted from [chardskarth's cursor_blaze gist](https://gist.github.com/chardskarth/95874c54e29da6b5a36ab7b50ae2d088).
