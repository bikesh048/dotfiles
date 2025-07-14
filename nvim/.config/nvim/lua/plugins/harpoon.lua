return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2", -- important!
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    harpoon:setup() -- required setup

    local list = harpoon:list()

    vim.keymap.set("n", "<leader>m", function()
      list:add()
    end, { desc = "Harpoon: Mark File" })

    vim.keymap.set("n", "<leader>a", function()
      harpoon.ui:toggle_quick_menu(list)
    end, { desc = "Toggle Harpoon Menu" })

    vim.keymap.set("n", "<leader>1", function()
      list:select(1)
    end, { desc = "Harpoon File 1" })
    vim.keymap.set("n", "<leader>2", function()
      list:select(2)
    end, { desc = "Harpoon File 2" })
    vim.keymap.set("n", "<leader>3", function()
      list:select(3)
    end, { desc = "Harpoon File 3" })
    vim.keymap.set("n", "<leader>4", function()
      list:select(4)
    end, { desc = "Harpoon File 4" })
    vim.keymap.set("n", "<leader>5", function()
      list:select(4)
    end, { desc = "HARPOON File 5" })
  end,
}
