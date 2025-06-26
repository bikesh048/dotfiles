vim.g.mapleader = " "
vim.g.maplocalleader = " "


require("core.globals")
require("core.keymaps")
require("core.options")

require("config.lazy")

vim.cmd("colorscheme tokyonight")
vim.cmd("hi IlluminatedWordText guibg=none gui=underline")
vim.cmd("hi IlluminatedWordRead guibg=none gui=underline")
vim.cmd("hi IlluminatedWordWrite guibg=none gui=underline")
