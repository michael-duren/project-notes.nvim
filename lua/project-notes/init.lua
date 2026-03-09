local M = {}

M.config = {
  data_dir = vim.fn.stdpath("data") .. "/project-notes",
  ext = ".md",
  window = {
    width = 0.6,
    height = 0.7,
    border = "rounded",
  },
  sort_by = "modified",
  mappings = {
    new_note = "n",
    delete_note = "d",
    edit_note = "<CR>",
    close = "q",
  },
  -- Picker preference: "auto", "snacks", "telescope"
  -- "auto" will use snacks if available, otherwise telescope
  picker = "auto",
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Create data directory if it doesn't exist
  vim.fn.mkdir(M.config.data_dir, "p")

  -- Register commands
  vim.api.nvim_create_user_command("ProjectNotes", function()
    require("project-notes.ui").open_browser()
  end, {})

  vim.api.nvim_create_user_command("ProjectNotesNew", function()
    require("project-notes.notes").create_note()
  end, {})

  vim.api.nvim_create_user_command("ProjectNotesFind", function()
    require("project-notes.picker").find_notes()
  end, {})
end

return M
