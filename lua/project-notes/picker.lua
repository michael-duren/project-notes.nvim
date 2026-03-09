local M = {}
local notes_module = require("project-notes.notes")
local config = require("project-notes").config

-- Detect which picker is available
local function get_picker()
  local picker_pref = config.picker or "auto"

  if picker_pref == "snacks" then
    local ok = pcall(require, "snacks")
    if ok then
      return "snacks"
    end
    vim.notify("Snacks.nvim not found, falling back to telescope", vim.log.levels.WARN)
  end

  if picker_pref == "telescope" then
    local ok = pcall(require, "telescope")
    if ok then
      return "telescope"
    end
    vim.notify("Telescope not found", vim.log.levels.WARN)
    return nil
  end

  -- Auto-detect
  if pcall(require, "snacks") then
    return "snacks"
  end

  if pcall(require, "telescope") then
    return "telescope"
  end

  return nil
end

-- Snacks.nvim picker implementation
local function find_notes_snacks()
  local snacks = require("snacks")
  local notes = notes_module.get_notes()

  if #notes == 0 then
    vim.notify("No notes found for this project", vim.log.levels.INFO)
    return
  end

  -- Format notes for snacks picker
  local items = {}
  for _, note in ipairs(notes) do
    table.insert(items, {
      text = note.title:gsub("_", " "),
      file = note.path,
      note = note,
    })
  end

  snacks.picker.pick({
    prompt = "Project Notes",
    items = items,
    preview = function(item)
      return {
        file = item.file,
      }
    end,
    confirm = function(item)
      vim.cmd("edit " .. vim.fn.fnameescape(item.file))
    end,
    format = function(item)
      return item.text
    end,
  })
end

-- Telescope picker implementation
local function find_notes_telescope()
  local has_telescope = pcall(require, "telescope.builtin")

  if not has_telescope then
    vim.notify(
      "Telescope is not installed. Install nvim-telescope/telescope.nvim or snacks.nvim to use this feature.",
      vim.log.levels.WARN
    )
    return
  end

  local notes = notes_module.get_notes()

  if #notes == 0 then
    vim.notify("No notes found for this project", vim.log.levels.INFO)
    return
  end

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

-- Main find_notes function that delegates to the appropriate picker
function M.find_notes()
  local picker = get_picker()

  if not picker then
    vim.notify(
      "No picker found. Install snacks.nvim or telescope.nvim to use this feature.",
      vim.log.levels.WARN
    )
    return
  end

  if picker == "snacks" then
    find_notes_snacks()
  elseif picker == "telescope" then
    find_notes_telescope()
  end
end

return M
