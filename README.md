# ghostty-lazer

My [Ghostty](https://ghostty.org) terminal configuration, focused on the
**"lazer" cursor** — a custom GLSL shader that fires a glowing blaze trail when
the cursor jumps across the screen.

## What's here

```
ghostty/
├── config                      # Ghostty config (wires up the shader)
└── shaders/
    └── cursor_blaze.glsl       # the laser cursor-trail shader
```

The relevant config lines:

```ini
custom-shader = shaders/cursor_blaze.glsl
custom-shader-animation = true
```

## Install

Ghostty reads its config from `~/.config/ghostty`. Symlink this repo's
`ghostty/` directory into place:

```sh
ln -s "$(pwd)/ghostty/config"  ~/.config/ghostty/config
ln -s "$(pwd)/ghostty/shaders" ~/.config/ghostty/shaders
```

Reload in-app with `⌘+Shift+,` (no restart needed).

## Tuning the lazer

Edit the constants at the top of `ghostty/shaders/cursor_blaze.glsl`:

| Constant            | Effect                                              |
| ------------------- | --------------------------------------------------- |
| `TRAIL_COLOR`       | Core trail color (currently amber/yellow)           |
| `TRAIL_COLOR_ACCENT`| Leading-edge accent color (currently red-orange)    |
| `DURATION`          | How long the trail lingers (seconds)                |
| `OPACITY`           | Trail opacity                                       |
| `DRAW_THRESHOLD`    | Min jump distance (× cursor size) before a trail draws — stops trails while typing |

Shader adapted from [chardskarth's cursor_blaze gist](https://gist.github.com/chardskarth/95874c54e29da6b5a36ab7b50ae2d088).
