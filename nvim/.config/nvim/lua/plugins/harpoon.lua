return {
  "theprimeagen/harpoon",
  branch = "harpoon2", -- important!
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    harpoon:setup() -- required setup

    local list = harpoon:list()

    vim.keymap.set("n", "<leader>m", function()
      list:add()
    end, { desc = "harpoon: mark file" })

    vim.keymap.set("n", "<leader>a", function()
      harpoon.ui:toggle_quick_menu(list)
    end, { desc = "toggle harpoon menu" })

    vim.keymap.set("n", "<leader>1", function()
      list:select(1)
    end, { desc = "harpoon file 1" })
    vim.keymap.set("n", "<leader>2", function()
      list:select(2)
    end, { desc = "harpoon file 2" })
    vim.keymap.set("n", "<leader>3", function()
      list:select(3)
    end, { desc = "harpoon file 3" })
    vim.keymap.set("n", "<leader>4", function()
      list:select(4)
    end, { desc = "harpoon file 4" })
    vim.keymap.set("n", "<leader>5", function()
      list:select(5)
    end, { desc = "harpoon file 5" })
  end,
}
