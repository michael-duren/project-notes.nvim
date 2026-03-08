local M = {}
local notes_module = require("project-notes.notes")

function M.find_notes()
  local has_telescope, telescope = pcall(require, "telescope.builtin")

  if not has_telescope then
    vim.notify("Telescope is not installed. Install nvim-telescope/telescope.nvim to use this feature.", vim.log.levels.WARN)
    return
  end

  local notes = notes_module.get_notes()

  if #notes == 0 then
    vim.notify("No notes found for this project", vim.log.levels.INFO)
    return
  end

  -- Use Telescope's grep_string to search note contents
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  -- Create a list of entries
  local entries = {}
  for _, note in ipairs(notes) do
    table.insert(entries, {
      value = note.path,
      display = note.title:gsub("_", " "),
      ordinal = note.title,
      path = note.path,
      note = note,
    })
  end

  pickers
    .new({}, {
      prompt_title = "Project Notes",
      finder = finders.new_table({
        results = entries,
        entry_maker = function(entry)
          return {
            value = entry.value,
            display = entry.display,
            ordinal = entry.ordinal,
            path = entry.path,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer({
        title = "Note Preview",
        define_preview = function(self, entry)
          conf.buffer_previewer_maker(entry.path, self.state.bufnr, {
            bufname = self.state.bufname,
            winid = self.state.winid,
          })
        end,
      }),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.cmd("edit " .. vim.fn.fnameescape(selection.path))
        end)
        return true
      end,
    })
    :find()
end

return M
