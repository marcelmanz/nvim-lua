-- require "profiler"
require "config.options"
require "config.diagnostics"

require "config.lazy"
require "config.colors"

require "config.commands"
require "config.keymaps"
require "config.keybind-helpers"
require "neovide"
require "config.autocmds"
require "lsp"

-- features
require "features.persistend-qfl"
require "features.update-fe-version"
require "features.incdec"
require "features.vale-accept"
require "features.diff"
require "features.paste"

-- code runners
require "features.runners.bash"
require "features.runners.c"
require "features.runners.rust"
require "features.runners.node"
require "features.runners.just"
require "features.runners.test"
require "features.runners.git"
require "features.runners.misc"

-- vim: ts=2 sts=2 sw=2 et
