# Colorscheme Notes

## Current

Loaded dynamically from `~/.cache/.theme_mode` (writes `light` or `dark`).

## Tried & Notes

| Color Scheme             | Variant        | Notes                                                                                      |
| ------------------------ | -------------- | ------------------------------------------------------------------------------------------ |
| `falcon`                 | dark           | Low contrast, easy on eyes. Fails with transparent background.                             |
| `apprentice`             | dark           | Minimalist, muted tones. Works well with `contrast_dark = "medium"`.                       |
| `citruszest`             | dark           | Vibrant, citrus-inspired. High energy.                                                     |
| `forestbones`            | dark           | Earthy greens/browns, calming.                                                             |
| `github_dark_colorblind` | dark           | GitHub dark adjusted for colorblind users.                                                 |
| `hybrid_reverse`         | dark/light mix | Balanced, modern.                                                                          |
| `jellybeans`             | dark           | Colorful, playful.                                                                         |
| `kanagawa-dragon`        | dark           | Japanese art inspired, rich/deep.                                                          |
| `kanagawa-bones`         | dark           | Softer kanagawa variant.                                                                   |
| `lunaperche`             | dark           | Cool, soothing night-sky tones. Was in options.lua at some point.                          |
| `tuscany-night`          | dark           | Warm, Tuscan-countryside-at-night feel.                                                    |
| `no-clown-fiesta`        | dark           | Muted, low-noise palette. Needs `require("no-clown-fiesta").setup { transparent = true }`. |
| `zellner`                | light          | Clean light theme.                                                                         |
| `shine`                  | light          | Clean light theme.                                                                         |
| `deepwhite`              | light          | Clean light theme.                                                                         |
| `makurai`                | dark           | No notes.                                                                                  |

---

## Apprentice Config Snippet

```lua
vim.g.apprentice_hls_lspreference = "bright_yellow"
vim.g.apprentice_hls_cursor       = "bright_yellow"
vim.g.apprentice_hls_highlight    = "bright_yellow"
vim.g.apprentice_contrast_dark    = "medium" -- or "soft"
vim.cmd.colorscheme "apprentice"
vim.api.nvim_set_hl(0, "Visual", { bg = "#222222" })
```

## no-clown-fiesta Config Snippet

```lua
require("no-clown-fiesta").setup { transparent = true }
vim.cmd.colorscheme "no-clown-fiesta"
```
