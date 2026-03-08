-- Example configuration for project-notes.nvim

-- Basic setup with defaults
require("project-notes").setup()

-- Or with custom configuration
require("project-notes").setup({
  -- Custom data directory
  data_dir = vim.fn.expand("~/.my-notes"),

  -- Custom window size
  window = {
    width = 0.8,
    height = 0.8,
    border = "double",
  },

  -- Sort by creation date instead of modified date
  sort_by = "created",

  -- Custom keymaps
  mappings = {
    new_note = "a",        -- 'a' for add
    delete_note = "x",     -- 'x' for delete
    edit_note = "<CR>",
    close = "<Esc>",       -- Escape to close
  },
})

-- Suggested keymaps
vim.keymap.set("n", "<leader>pn", "<cmd>ProjectNotes<cr>", { desc = "Project notes" })
vim.keymap.set("n", "<leader>pa", "<cmd>ProjectNotesNew<cr>", { desc = "New project note" })
vim.keymap.set("n", "<leader>pf", "<cmd>ProjectNotesFind<cr>", { desc = "Find project note" })
