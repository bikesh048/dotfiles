return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview file history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview branch history" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
  },
  config = function()
    require("diffview").setup({
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_horizontal",
        },
      },
    })
  end,
}
