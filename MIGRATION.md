# Migration Guide

## Upgrading to Snacks.nvim Support

If you're upgrading from an earlier version that only supported Telescope, here's what you need to know:

### Breaking Changes

**None!** The plugin is fully backward compatible.

### New Features

The plugin now supports **both** Snacks.nvim and Telescope:

1. **Snacks.nvim** (recommended) - Provides enhanced floating windows and picker
2. **Telescope** (still supported) - Original picker implementation

### What You Need to Do

**Option 1: Switch to Snacks.nvim (Recommended)**

Update your plugin configuration:

```lua
{
    "michael-duren/project-notes.nvim",
    dependencies = {
        "folke/snacks.nvim", -- Add this
    },
    opts = {
        picker = "snacks", -- Optional: force snacks
    },
}
```

**Option 2: Keep Using Telescope**

No changes needed! Your existing configuration will continue to work:

```lua
{
    "michael-duren/project-notes.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    opts = {
        picker = "telescope", -- Optional: force telescope
    },
}
```

**Option 3: Auto-detect (Default)**

The plugin will automatically use Snacks if available, otherwise Telescope:

```lua
{
    "michael-duren/project-notes.nvim",
    dependencies = {
        "folke/snacks.nvim", -- optional
        "nvim-telescope/telescope.nvim", -- optional
    },
    opts = {
        picker = "auto", -- This is the default
    },
}
```

### Benefits of Snacks.nvim

- Better floating window styling with titles
- Consistent UI with other Snacks-powered plugins
- Faster and lighter weight picker
- More modern window management

### Configuration Changes

New config option:

```lua
require("project-notes").setup({
    -- New option: choose your picker
    picker = "auto", -- or "snacks" or "telescope"
})
```

All other configuration options remain the same.

### API Changes

**Internal only** - if you were calling `require("project-notes.telescope")` directly:

```lua
-- Old (still works but deprecated)
require("project-notes.telescope").find_notes()

-- New (recommended)
require("project-notes.picker").find_notes()
```

The `:ProjectNotesFind` command works the same way regardless of which picker you use.
