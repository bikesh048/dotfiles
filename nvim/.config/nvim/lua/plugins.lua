return {
  {
    "nvim-neotest/nvim-nio",
  },

  -- {
  --   "MeanderingProgrammer/render-markdown.nvim",
  --   opts = {},
  --   dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
  -- },
  -- {
  --   "chentoast/marks.nvim",
  --   config = function()
  --     require("marks").setup({
  --       default_mappings = true,
  --     })
  --   end,
  -- },

  -- {
  --   "nvim-treesitter/nvim-treesitter-context",
  --   config = function()
  --     require("treesitter-context").setup({
  --       max_lines = 5,
  --     })
  --   end,
  -- },
  -- {
  --   "RRethy/vim-illuminate",
  --   config = function()
  --     require("illuminate")
  --   end,
  -- },

  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  -- {
  --   "catppuccin/nvim",
  -- },
  -- {
  --   "ellisonleao/gruvbox.nvim",
  -- },
  {
    "exosyphon/telescope-color-picker.nvim",
    config = function()
      vim.keymap.set("n", "<leader>uC", "<cmd>Telescope colors<CR>", { desc = "Telescope Color Picker" })
    end,
  },
  -- {
  --   "mbbill/undotree",
  --   config = function()
  --     vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<CR>", { desc = "Telescope Undo" })
  --   end,
  -- },
  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Open Fugitive Panel" })
    end,
  },
  "tpope/vim-repeat",
  -- {
  --   "numToStr/Comment.nvim",
  --   config = function()
  --     require("Comment").setup()
  --   end,
  -- },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  -- {
  --   "junegunn/fzf",
  --   build = ":call fzf#install()",
  -- },
  -- "nanotee/zoxide.vim",
  "nvim-telescope/telescope-ui-select.nvim",
  "debugloop/telescope-undo.nvim",

 -- "mg979/vim-visual-multi",

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
    end,
    opts = {
      triggers = {
        { "<auto>", mode = "nxso" },
      },
    },
  },
  { "nvim-telescope/telescope-live-grep-args.nvim" },
  {
    "aaronhallaert/advanced-git-search.nvim",
    dependencies = {
      "tpope/vim-fugitive",
      "tpope/vim-rhubarb",
    },
  },
}
