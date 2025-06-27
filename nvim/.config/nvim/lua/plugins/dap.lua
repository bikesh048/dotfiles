return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      config = function(_, opts)
        local dap = require("dap")
        local dapui = require("dapui")
        dap.set_log_level("INFO")
        dapui.setup(opts)
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open({})
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close({})
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close({})
        end
      end,
    },
    ,
    ,
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },
    {
      "jay-babu/mason-nvim-dap.nvim",
      dependencies = "mason.nvim",
      cmd = { "DapInstall", "DapUninstall" },
      opts = {
        automatic_installation = true,
        ensure_installed = {
          "delve",         -- for Go
          "js-debug-adapter", -- vscode-js-debug for JS/TS debugging
        },
      },
    },
    { "jbyuki/one-small-step-for-vimkind", module = "osv" },

    -- Add nvim-dap-vscode-js for JavaScript/TypeScript debugging
    {
      "mxsdev/nvim-dap-vscode-js",
      ft = { "javascript", "typescript", "typescriptreact", "javascriptreact" },
      dependencies = { "mfussenegger/nvim-dap" },
      config = function()
        local dap = require("dap")
        local dap_vscode_js = require("dap-vscode-js")

        dap_vscode_js.setup({
          debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter", -- mason installation path
          adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
        })

        for _, language in ipairs({ "typescript", "typescriptreact", "javascript", "javascriptreact" }) do
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
              sourceMaps = true,
              protocol = "inspector",
              console = "integratedTerminal",
              outFiles = { "${workspaceFolder}/dist/**/*.js" }, -- adjust if your compiled JS output differs
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach to process",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
              sourceMaps = true,
              protocol = "inspector",
            },
          }
        end
      end,
    },
  },
}

