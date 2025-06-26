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
        "prettier",
        "prettierd",
        "ktlint",
        "eslint_d",
        "google-java-format",
        "htmlbeautifier",
        "beautysh",
        "buf",
        "rustfmt",
        "yamlfix",
        "taplo",
        "shellcheck",
        "gopls",
        "delve",
        "astro-language-server",
      },
    })
  end,
}
