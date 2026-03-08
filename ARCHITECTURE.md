# Project Notes Architecture

## Overview

Project Notes is structured as a modular Neovim plugin following standard Neovim plugin conventions.

## Directory Structure

```
project-notes.nvim/
├── lua/project-notes/       # Core plugin code
│   ├── init.lua             # Entry point, setup(), config
│   ├── git.lua              # Git repository detection and hashing
│   ├── notes.lua            # Notes CRUD operations
│   ├── ui.lua               # Floating window UI
│   └── telescope.lua        # Telescope integration
├── plugin/                  # Plugin initialization
│   └── project-notes.lua    # Auto-loads the plugin
├── doc/                     # Vim help documentation
│   └── project-notes.txt    # Help file
├── examples/                # Example configurations
│   └── init.lua             # Sample setup
└── README.md                # User documentation
```

## Module Responsibilities

### `lua/project-notes/init.lua`

- Plugin entry point
- Exports `setup()` function
- Stores configuration
- Registers user commands (`:ProjectNotes`, `:ProjectNotesNew`, `:ProjectNotesFind`)

### `lua/project-notes/git.lua`

- Finds `.git` directory by walking up the file tree
- Handles both regular git dirs and worktrees (`.git` as a file)
- Extracts remote origin URL from `.git/config`
- Generates SHA-256 hash of remote URL or git directory path
- Returns project identifier and metadata

### `lua/project-notes/notes.lua`

- Manages notes directory structure
- Creates and maintains `meta.json` for project metadata
- Implements CRUD operations:
  - `get_notes()` - Lists all notes with metadata
  - `create_note()` - Creates new note with template
  - `edit_note()` - Opens note in buffer
  - `delete_note()` - Deletes note with confirmation
- Handles note sorting (by created, modified, or title)

### `lua/project-notes/ui.lua`

- Creates and manages floating window
- Renders notes list with Markdown formatting
- Implements browser keymaps (n, d, Enter, q)
- Handles cursor positioning and note selection
- Provides live preview of note content

### `lua/project-notes/telescope.lua`

- Optional Telescope integration
- Provides fuzzy finding interface for notes
- Shows note preview in Telescope
- Handles note selection and opening

## Data Flow

### Opening Notes Browser

```
User: :ProjectNotes
  ↓
init.lua (command handler)
  ↓
ui.open_browser()
  ↓
notes.get_notes()
  ↓
git.get_project_id() → project hash
  ↓
Read notes from ~/.local/share/nvim/project-notes/<hash>/
  ↓
Render in floating window
```

### Creating a Note

```
User: :ProjectNotesNew (or 'n' in browser)
  ↓
notes.create_note()
  ↓
Prompt for title
  ↓
git.get_project_id() → project hash
  ↓
Generate timestamp + sanitized filename
  ↓
Write note with template
  ↓
Open in buffer for editing
```

## Storage Format

### Directory Structure

```
~/.local/share/nvim/project-notes/
└── <sha256-hash>/
    ├── meta.json
    ├── 1710000000_setup.md
    ├── 1710100000_todo.md
    └── 1710200000_arch.md
```

### meta.json

```json
{
  "name": "user/repository",
  "remote_url": "git@github.com:user/repository.git",
  "created": 1710000000
}
```

### Note File Format

Filename: `<unix-timestamp>_<sanitized-title>.md`

```markdown
# Note Title

**Project:** user/repository
**Created:** 2024-03-09 12:00:00

---

[Note content...]
```

## Key Design Decisions

### 1. Hash-based Project Identification

Using SHA-256 hash of remote URL ensures:
- Stable identifier across clones and directory moves
- No collision with other projects
- Works with worktrees (share same remote)
- Fallback to path hash for local-only repos

### 2. Timestamp-based Filenames

Using Unix timestamps as filename prefixes:
- Natural chronological ordering
- No filename conflicts
- Easy to sort programmatically
- Preserves creation time in filename

### 3. Separate UI Module

Isolating UI logic:
- Makes testing easier
- Allows for alternative interfaces (future TUI, etc.)
- Keeps core logic separate from presentation

### 4. Optional Telescope Integration

Making Telescope optional:
- Reduces dependencies for basic use
- Provides enhanced experience when available
- Graceful degradation with helpful message

## Extension Points

### Adding New Commands

Add to `init.lua`:
```lua
vim.api.nvim_create_user_command("ProjectNotesMyCommand", function()
  require("project-notes.my_module").my_function()
end, {})
```

### Custom Note Templates

Modify `notes.create_note()` to customize the initial note content.

### Alternative Sorting

Add new sort options in `notes.get_notes()` sorting logic.

### Different Preview Renderers

Extend `ui.lua` to support different Markdown renderers or formats.

## Testing Approach

### Manual Testing

1. Test in a repo with remote origin
2. Test in a local-only repo
3. Test in a worktree
4. Test with multiple projects
5. Test all CRUD operations

### Edge Cases

- No `.git` directory (should show warning)
- `.git` is a file (worktree scenario)
- No remote origin (should use path hash)
- Empty project (should allow note creation)
- Concurrent edits (handled by Neovim's buffer system)

## Performance Considerations

- Git operations are synchronous but fast (reading local files)
- SHA-256 hashing is done via system command (fast)
- Note listing uses `vim.fn.glob()` (efficient for small sets)
- UI renders on-demand, not continuously
- No watchers or timers (event-driven only)

## Future Enhancements

Potential improvements:
- [ ] Full-text search across all notes
- [ ] Note tags/categories
- [ ] Note templates
- [ ] Export notes to different formats
- [ ] Sync notes across machines
- [ ] Note linking (wiki-style)
- [ ] Note archiving
- [ ] Integration with other note-taking tools
