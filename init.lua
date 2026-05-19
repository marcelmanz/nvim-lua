-- require "profiler"
require "options"

require "lazy-plugins"

require "commands"
require "keymaps"
require "keybind-helpers"
require "neovide"
require "autocmd"
require "color-settings"
require "tmux"
require "lsp"

-- features
require "features.persistend-qfl"
require "features.update-fe-version"
require "features.incdec"
require "features.vale-accept"
require "features.diff"
require 'features.paste'

-- code runners
require "runners.bash"
require "runners.c"
require "runners.rust"
require "runners.node"
require "runners.just"
require "runners.test"
require "runners.git"
require "runners.misc"

-------------------------------------------------------------------------------
-- -- vim: ts=2 sts=2 sw=2 et
