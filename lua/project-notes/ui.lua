local M = {}
local notes_module = require("project-notes.notes")
local config = require("project-notes").config

local buf, win
local current_notes = {}

-- Create centered floating window using Snacks if available, otherwise vanilla Neovim
local function create_floating_window()
  local has_snacks, snacks = pcall(require, "snacks")

  -- Create buffer
  buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

  if has_snacks and snacks.win then
    -- Use Snacks.nvim for enhanced window management
    local snacks_win = snacks.win({
      buf = buf,
      relative = "editor",
      width = config.window.width,
      height = config.window.height,
      border = config.window.border,
      title = " Project Notes ",
      title_pos = "center",
      wo = {
        wrap = true,
        linebreak = true,
        cursorline = true,
      },
    })
    win = snacks_win.win
  else
    -- Fallback to vanilla Neovim floating window
    local width = math.floor(vim.o.columns * config.window.width)
    local height = math.floor(vim.o.lines * config.window.height)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local opts = {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = config.window.border,
    }

    win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_win_set_option(win, "wrap", true)
    vim.api.nvim_win_set_option(win, "linebreak", true)
    vim.api.nvim_win_set_option(win, "cursorline", true)
  end

  return buf, win
end

-- Format a timestamp for display
local function format_time(timestamp)
  return os.date("%Y-%m-%d %H:%M", timestamp)
end

-- Render the notes list in the buffer
local function render_notes_list(notes)
  current_notes = notes
  local lines = {}
  local meta = notes_module.get_project_meta()

  -- Header
  if meta then
    table.insert(lines, "# Project Notes: " .. meta.name)
    if meta.remote_url and meta.remote_url ~= "" then
      table.insert(lines, "> " .. meta.remote_url)
    end
  else
    table.insert(lines, "# Project Notes")
  end

  table.insert(lines, "")
  table.insert(lines, string.format("**%d note%s** | Sort by: %s", #notes, #notes == 1 and "" or "s", config.sort_by))
  table.insert(lines, "")
  table.insert(lines, "---")
  table.insert(lines, "")

  -- Help text
  table.insert(lines, "_Keys: `" .. config.mappings.new_note .. "` new | `" .. config.mappings.delete_note .. "` delete | `" .. config.mappings.edit_note .. "` edit | `" .. config.mappings.close .. "` close_")
  table.insert(lines, "")
  table.insert(lines, "---")
  table.insert(lines, "")

  -- Notes list
  if #notes == 0 then
    table.insert(lines, "_No notes yet. Press `" .. config.mappings.new_note .. "` to create one._")
  else
    for _, note in ipairs(notes) do
      table.insert(lines, "## " .. note.title:gsub("_", " "))
      table.insert(lines, "")
      table.insert(lines, "- **Created:** " .. format_time(note.created))
      table.insert(lines, "- **Modified:** " .. format_time(note.modified))
      table.insert(lines, "")

      -- Preview first few lines of the note
      if vim.fn.filereadable(note.path) == 1 then
        local content = vim.fn.readfile(note.path)
        local preview_lines = 0
        local max_preview = 3

        for _, line in ipairs(content) do
          -- Skip the title and metadata we already show
          if not line:match("^#") and not line:match("^%*%*Project:") and not line:match("^%*%*Created:") and line ~= "---" and line ~= "" then
            if preview_lines < max_preview then
              table.insert(lines, "> " .. line)
              preview_lines = preview_lines + 1
            end
          end
        end

        if preview_lines > 0 then
          table.insert(lines, "")
        end
      end

      table.insert(lines, "---")
      table.insert(lines, "")
    end
  end

  -- Set buffer content
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "modified", false)
end

-- Get the note under the cursor
local function get_note_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = cursor[1]

  -- Find which note section we're in by looking backwards for "## " headers
  for i = line, 1, -1 do
    local text = vim.api.nvim_buf_get_lines(buf, i - 1, i, false)[1]
    if text and text:match("^## ") then
      local title = text:match("^## (.*)")
      if title then
        -- Find the note with this title
        for _, note in ipairs(current_notes) do
          if note.title:gsub("_", " ") == title then
            return note
          end
        end
      end
      break
    end
  end

  return nil
end

-- Set up keymaps for the browser
local function setup_keymaps()
  local mappings = config.mappings

  -- Close window
  vim.keymap.set("n", mappings.close, function()
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, nowait = true })

  -- Create new note
  vim.keymap.set("n", mappings.new_note, function()
    -- Close the browser window
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    notes_module.create_note()
  end, { buffer = buf, nowait = true })

  -- Edit note
  vim.keymap.set("n", mappings.edit_note, function()
    local note = get_note_at_cursor()
    if note then
      -- Close the browser window
      if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      notes_module.edit_note(note)
    end
  end, { buffer = buf, nowait = true })

  -- Delete note
  vim.keymap.set("n", mappings.delete_note, function()
    local note = get_note_at_cursor()
    if note then
      notes_module.delete_note(note)
      -- Refresh the browser
      vim.defer_fn(function()
        if win and vim.api.nvim_win_is_valid(win) then
          local updated_notes = notes_module.get_notes()
          render_notes_list(updated_notes)
        end
      end, 100)
    end
  end, { buffer = buf, nowait = true })
end

-- Open the notes browser
function M.open_browser()
  local notes = notes_module.get_notes()

  create_floating_window()
  render_notes_list(notes)
  setup_keymaps()

  -- Set cursor to first note if available
  if #notes > 0 then
    -- Find the first "## " line (first note title)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i, line in ipairs(lines) do
      if line:match("^## ") then
        vim.api.nvim_win_set_cursor(win, { i, 0 })
        break
      end
    end
  end
end

return M
