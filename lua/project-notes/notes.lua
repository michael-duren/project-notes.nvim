local M = {}
local git = require("project-notes.git")
local config = require("project-notes").config

-- Get the notes directory for the current project
local function get_project_notes_dir()
  local project_id, project_name, remote_url = git.get_project_id()
  if not project_id then
    return nil
  end

  local notes_dir = config.data_dir .. "/" .. project_id
  vim.fn.mkdir(notes_dir, "p")

  -- Create or update meta.json
  local meta_path = notes_dir .. "/meta.json"
  local meta = {
    name = project_name or "Unknown",
    remote_url = remote_url or "",
    created = os.time(),
  }

  -- Read existing meta if it exists to preserve created time
  if vim.fn.filereadable(meta_path) == 1 then
    local ok, existing = pcall(function()
      return vim.fn.json_decode(vim.fn.readfile(meta_path))
    end)
    if ok and existing.created then
      meta.created = existing.created
    end
  end

  vim.fn.writefile({ vim.fn.json_encode(meta) }, meta_path)

  return notes_dir, project_name
end

-- Get all note files in the project directory
function M.get_notes()
  local notes_dir = get_project_notes_dir()
  if not notes_dir then
    return {}
  end

  local files = vim.fn.glob(notes_dir .. "/*" .. config.ext, false, true)
  local notes = {}

  for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file, ":t")
    -- Skip meta.json and other non-note files
    if filename ~= "meta.json" then
      local timestamp_str, title = filename:match("^(%d+)_(.*)%.md$")
      if timestamp_str and title then
        local stat = vim.loop.fs_stat(file)
        table.insert(notes, {
          path = file,
          filename = filename,
          title = title,
          created = tonumber(timestamp_str),
          modified = stat and stat.mtime.sec or 0,
        })
      end
    end
  end

  -- Sort notes
  if config.sort_by == "created" then
    table.sort(notes, function(a, b)
      return a.created > b.created
    end)
  elseif config.sort_by == "modified" then
    table.sort(notes, function(a, b)
      return a.modified > b.modified
    end)
  elseif config.sort_by == "title" then
    table.sort(notes, function(a, b)
      return a.title < b.title
    end)
  end

  return notes
end

-- Create a new note
function M.create_note()
  local notes_dir, project_name = get_project_notes_dir()
  if not notes_dir then
    return
  end

  vim.ui.input({ prompt = "Note title: " }, function(title)
    if not title or title == "" then
      return
    end

    -- Sanitize title for filename
    local safe_title = title:gsub("[^%w%s-]", ""):gsub("%s+", "_"):lower()
    local timestamp = os.time()
    local filename = string.format("%d_%s%s", timestamp, safe_title, config.ext)
    local filepath = notes_dir .. "/" .. filename

    -- Create note with template
    local lines = {
      "# " .. title,
      "",
      "**Project:** " .. (project_name or "Unknown"),
      "**Created:** " .. os.date("%Y-%m-%d %H:%M:%S", timestamp),
      "",
      "---",
      "",
      "",
    }

    vim.fn.writefile(lines, filepath)
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
    vim.notify("Created note: " .. title, vim.log.levels.INFO)
  end)
end

-- Delete a note
function M.delete_note(note)
  vim.ui.select({ "Yes", "No" }, {
    prompt = "Delete note '" .. note.title .. "'?",
  }, function(choice)
    if choice == "Yes" then
      vim.fn.delete(note.path)
      vim.notify("Deleted note: " .. note.title, vim.log.levels.INFO)
    end
  end)
end

-- Open a note for editing
function M.edit_note(note)
  vim.cmd("edit " .. vim.fn.fnameescape(note.path))
end

-- Get project metadata
function M.get_project_meta()
  local notes_dir = get_project_notes_dir()
  if not notes_dir then
    return nil
  end

  local meta_path = notes_dir .. "/meta.json"
  if vim.fn.filereadable(meta_path) == 0 then
    return nil
  end

  local ok, meta = pcall(function()
    return vim.fn.json_decode(vim.fn.readfile(meta_path))
  end)

  return ok and meta or nil
end

return M
