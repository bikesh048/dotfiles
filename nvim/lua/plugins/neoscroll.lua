return {
  "karb94/neoscroll.nvim",

  opts = {
    -- Whether to hide the cursor while scrolling
    hide_cursor = true,

    -- The easing function used for scrolling animation
    easing_function = "quadratic", -- or "circular", "sine", "quartic", etc.

    -- Time (in ms) between scroll steps
    time = 150,

    -- Number of lines to scroll per step
    scroll_amount = 5,

    -- Stop at the end of file or keep scrolling
    stop_eof = true,

    -- Respect scrolloff margin when scrolling vertically
    respect_scrolloff = false,

    -- Allow cursor to scroll past the screen edge
    cursor_scrolls_alone = true,

    -- Define custom mappings (can also be set separately)
    mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zz", "zt", "zb" },
  },
}
