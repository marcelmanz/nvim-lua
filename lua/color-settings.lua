vim.o.termguicolors = true
local theme_file = vim.fn.expand "$HOME/.cache/.theme_mode"
local theme_file = io.open(theme_file, "r")
if theme_file then
	vim.o.background = theme_file:read "*l" or "dark"
	theme_file:close()
else
	vim.o.background = "dark"
end
vim.cmd.set "t_Co=256"

-- For some reason falcon fails when setting a transparent background
-- vim.cmd.colorscheme "citruszest"
-- vim.cmd.colorscheme "falcon"

-- require("no-clown-fiesta").setup { transparent = true }
-- vim.cmd.colorscheme "no-clown-fiesta"
-- vim.cmd.colorscheme "zellner"
-- vim.cmd.colorscheme "makurai"
-- vim.cmd.colorscheme "lunaperche" -- Moved to options.lua
vim.cmd "hi VertSplit guifg=#373737 guibg=#373737gui=NONE cterm=NONE"
-- vim.g.apprentice_contrast_dark = "soft"

-- vim.api.nvim_create_autocmd("colorscheme", {
-- 	pattern = "*",
-- 	callback = function()
-- 		-- single-color foreground; see discussions at:
-- 		-- https://github.com/echasnovski/mini.nvim/issues/538
-- 		vim.cmd [[highlight! link DiffAdd    DiagnosticOk]]
-- 		vim.cmd [[highlight! link DiffChange DiagnosticWarn]]
-- 		vim.cmd [[highlight! link DiffDelete DiagnosticError]]
-- 	end,
-- })

-- apprentice
-- vim.g.apprentice_hls_lspreference = "bright_yellow"
-- vim.g.apprentice_hls_cursor = "bright_yellow"
-- vim.g.apprentice_hls_highlight = "bright_yellow"
-- vim.g.apprentice_contrast_dark = "medium"
-- vim.cmd.colorscheme "apprentice"
-- vim.api.nvim_set_hl(0, "Visual", { bg = "#222222" })
--

-- require("ziggy").style()
-- require("zig-official-color").setup()

-- vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#373737" })

-- # best light themes
-- - zellner
-- - shine
-- - deepwhite

-- # Favorite color schemes
-- | Color Scheme              | Description                                                                                                               |
-- | ------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
-- | falcon                    | A dark color scheme with a focus on low contrast, making it easy on the eyes during long coding sessions.                 |
-- | apprentice                | A minimalistic color scheme with muted tones, designed to reduce visual noise and distraction.                            |
-- | citruszest                | A vibrant and refreshing color scheme with bright, citrus-inspired colors that bring energy to the workspace.             |
-- | forestbones               | A nature-inspired color scheme with earthy greens and browns, providing a calming and grounded environment.               |
-- | github_dark_colorblind    | A dark version of GitHub's color scheme, specifically adjusted to be accessible for colorblind users.                     |
-- | hybrid_reverse            | A reverse hybrid color scheme that combines light and dark elements for a balanced, modern look.                          |
-- | jellybeans                | A playful and colorful scheme with a variety of bright hues, reminiscent of jellybeans, adding a touch of fun to coding.  |
-- | kanagawa-dragon           | Inspired by Japanese art, this scheme features rich and deep colors with a traditional aesthetic.                         |
-- | kanagawa-bones            | Another variant of the Kanagawa theme, focusing on softer, bone-like colors for a more subdued look.                      |
-- | lunaperche                | A celestial-themed color scheme with cool, soothing colors that evoke the tranquility of the night sky.                   |
-- | tuscany-night             | Inspired by a trip to Italy. The colors are warm and inviting, reminiscent of the Tuscan countryside at night.            |
-- | no-clown-fiesta           | A color scheme that aims to reduce visual noise and distraction by using a limited palette of soft, muted colors.         |
