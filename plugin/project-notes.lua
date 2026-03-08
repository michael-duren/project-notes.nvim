-- plugin/project-notes.lua
-- This file ensures the plugin is loaded when Neovim starts

if vim.g.loaded_project_notes then
  return
end
vim.g.loaded_project_notes = true
