return {
  "williamboman/mason.nvim",
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        -- Formatters
        "prettier",
        "prettierd",
        "stylua",
        "htmlbeautifier",
        "beautysh",
        "buf",
        -- Linters
        "eslint_d",
        "shellcheck",
        -- yamllint & ansible-lint: install via brew (more reliable)
        -- brew install yamllint ansible-lint
        -- LSP servers
        "astro-language-server",
        "ansible-language-server",
        "yaml-language-server",
      },
    })
  end,
}
