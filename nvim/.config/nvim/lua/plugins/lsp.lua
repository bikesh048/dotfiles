return {
  "VonHeikemen/lsp-zero.nvim",
  branch = "v2.x",
  dependencies = {
    -- LSP Support
    { "neovim/nvim-lspconfig" },
    {
      "williamboman/mason.nvim",
      build = function()
        pcall(vim.cmd, "MasonUpdate")
      end,
    },
    { "williamboman/mason-lspconfig.nvim" },

    -- Autocompletion
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip" },
    { "rafamadriz/friendly-snippets" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "saadparwaiz1/cmp_luasnip" },
  },
  config = function()
    local lsp = require("lsp-zero")

    lsp.on_attach(function(client, bufnr)
      local opts = { buffer = bufnr, remap = false }
      local map = vim.keymap.set

      map("n", "gd", vim.lsp.buf.definition, opts)
      map("n", "K", vim.lsp.buf.hover, opts)
      map("n", "<leader>vca", vim.lsp.buf.code_action, opts)
      map("n", "<leader>vrn", vim.lsp.buf.rename, opts)
      map("n", "<leader>vd", vim.diagnostic.open_float, opts)
      map("n", "[d", vim.diagnostic.goto_next, opts)
      map("n", "]d", vim.diagnostic.goto_prev, opts)
      map("n", "<leader>vca", vim.lsp.buf.code_action, opts)
      map("n", "<leader>vrr", vim.lsp.buf.references, opts)
      map("n", "<leader>vrn", vim.lsp.buf.rename, opts)
      map("i", "<C-h>", vim.lsp.buf.signature_help, opts)

      map("n", "<leader>li", function()
        vim.lsp.buf.code_action({
          context = { only = { "source.addMissingImports.ts" }, diagnostics = {} },
          apply = true,
        })
      end, opts)
    end)

    require("mason").setup()

    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "ts_ls", -- JavaScript / TypeScript
        "tsp_server",
        "eslint",   -- optional: for eslint CLI
      },
      handlers = {
        lsp.default_setup,
        lua_ls = function()
          local lua_opts = lsp.nvim_lua_ls()
          require("lspconfig").lua_ls.setup(lua_opts)
        end,
        tsserver = function()
          require("lspconfig").tsserver.setup({
            on_attach = function(client, bufnr)
              client.server_capabilities.documentFormattingProvider = false
              vim.keymap.set("n", "<leader>li", function()
                vim.lsp.buf.code_action({
                  context = { only = { "source.addMissingImports.ts" }, diagnostics = {} },
                  apply = true,
                })
              end, { buffer = bufnr, desc = "Auto Import Missing TS Imports" })
            end,
            settings = {
              typescript = {
                preferences = {
                  importModuleSpecifierPreference = "non-relative",
                  includeCompletionsForModuleExports = true,
                },
              },
              javascript = {
                preferences = {
                  importModuleSpecifierPreference = "non-relative",
                  includeCompletionsForModuleExports = true,
                },
              },
            },
          })
        end,
      },
    })

    -- Optional: Add auto-import on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
      callback = function()
        vim.lsp.buf.code_action({
          context = { only = { "source.addMissingImports.ts" }, diagnostics = {} },
          apply = true,
        })
      end,
    })

    vim.diagnostic.config({
      virtual_text = false,
      signs = true,
      underline = true,
      update_in_insert = false,
    })

    -- CMP Setup
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local cmp_action = lsp.cmp_action()
    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip", keyword_length = 2 },
        { name = "buffer",  keyword_length = 3 },
        { name = "path" },
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
        ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-f>"] = cmp_action.luasnip_jump_forward(),
        ["<C-b>"] = cmp_action.luasnip_jump_backward(),
        ["<Tab>"] = cmp_action.luasnip_supertab(),
        ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
      }),
    })

    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } },
      }),
    })
  end,
}

