return {
  "voldikss/vim-floaterm",
  config = function()
    vim.keymap.set(
      "n",
      "<leader>ft",
      "<cmd>:FloatermNew --cwd=<buffer> --height=0.7 --width=0.8 --wintype=float --name=floaterm1 --position=center --autoclose=2<CR>",
      { desc = "Open FloatTerm in buffer's CWD" }
    )
    vim.keymap.set("n", "<leader>flt", "<cmd>:FloatermToggle<CR>", { desc = "Toggle FloatTerm" })
    vim.keymap.set("t", "<leader>flt", "<cmd>:FloatermToggle<CR>", { desc = "Toggle FloatTerm" })
  end,
}

