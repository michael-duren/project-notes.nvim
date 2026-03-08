# Project Notes

A Neovim plugin for managing per-project notes. Notes are stored in your XDG data directory and automatically associated with Git repositories, so your notes follow your projects without cluttering your repos.

## About

Project Notes identifies each project by hashing the Git remote origin URL from `.git/config`. This means your notes persist across clones, worktrees, and directory renames — as long as the remote is the same, your notes are found. For repos without a remote, it falls back to hashing the path of the `.git` directory.

Notes are stored as plain Markdown files in `~/.local/share/nvim/project-notes/<hash>/`, keeping them out of your repository and version control.

## Features

- **Per-project notes** — notes are scoped to the Git repository you're working in
- **Browse notes** — scroll through existing notes in a floating window
- **Create notes** — add new notes with a title and body
- **Edit notes** — open any note in a buffer for editing
- **Delete notes** — remove notes you no longer need
- **Timestamps** — notes are automatically timestamped on creation and last edit
- **Telescope integration** — fuzzy find across all notes in the current project
- **Markdown preview** — notes are rendered as Markdown in the floating window

## Requirements

- Neovim >= 0.9.0
- Git
- (Optional) [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) for fuzzy finding notes

## Installation

### lazy.nvim

```lua
{
    "yourname/project-notes.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim", -- optional
    },
    opts = {},
}
```

### packer.nvim

```lua
use {
    "yourname/project-notes.nvim",
    requires = {
        "nvim-telescope/telescope.nvim", -- optional
    },
    config = function()
        require("project-notes").setup()
    end,
}
```

## Configuration

```lua
require("project-notes").setup({
    -- Directory where notes are stored
    -- Default: vim.fn.stdpath("data") .. "/project-notes"
    data_dir = nil,

    -- Default file extension for new notes
    ext = ".md",

    -- Floating window dimensions (0.0 - 1.0 = percentage of editor)
    window = {
        width = 0.6,
        height = 0.7,
        border = "rounded",
    },

    -- Sort order for note list: "created", "modified", "title"
    sort_by = "modified",

    -- Key mappings inside the notes browser
    mappings = {
        new_note = "n",
        delete_note = "d",
        edit_note = "<CR>",
        close = "q",
    },
})
```

## Usage

### Commands

| Command | Description |
|---|---|
| `:ProjectNotes` | Open the notes browser for the current project |
| `:ProjectNotesNew` | Create a new note |
| `:ProjectNotesFind` | Fuzzy find notes with Telescope |

### Keymaps

No keymaps are set by default. Suggested mappings:

```lua
vim.keymap.set("n", "<leader>pn", "<cmd>ProjectNotes<cr>", { desc = "Project notes" })
vim.keymap.set("n", "<leader>pa", "<cmd>ProjectNotesNew<cr>", { desc = "New project note" })
vim.keymap.set("n", "<leader>pf", "<cmd>ProjectNotesFind<cr>", { desc = "Find project note" })
```

### Notes Browser

When you open the notes browser with `:ProjectNotes`, you'll see a floating window listing all notes for the current project. From there:

- `<CR>` — open the selected note for editing
- `n` — create a new note
- `d` — delete the selected note (with confirmation)
- `q` — close the browser

## How It Works

1. When invoked, the plugin walks up from the current buffer's directory to find the nearest `.git` directory
2. It reads `.git/config` and extracts the `remote "origin"` URL
3. The URL is hashed with SHA-256 to produce a stable project identifier
4. If no remote exists, the absolute path of the `.git` directory is hashed instead
5. Notes are stored as individual Markdown files under `~/.local/share/nvim/project-notes/<hash>/`

This approach means:
- Cloning the same repo to a different path still finds your notes
- Multiple worktrees of the same repo share notes
- Local-only repos (no remote) still get their own note space
- Notes never pollute your repository or show up in `git status`

## File Structure

```
~/.local/share/nvim/project-notes/
└── a1b2c3d4e5f6.../
    ├── meta.json            # project metadata (name, remote URL)
    ├── 1710000000_setup.md
    ├── 1710100000_todo.md
    └── 1710200000_arch.md
```

Each note filename is prefixed with a Unix timestamp of creation for natural ordering. `meta.json` stores the project name and remote URL for display purposes.

## License

MIT
