# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- **Snacks.nvim integration** - Full support for Snacks.nvim as the preferred UI framework
  - Enhanced floating windows with titles and better styling via `snacks.win`
  - Native picker support via `snacks.picker` for fuzzy finding notes
  - Automatic fallback to vanilla Neovim or Telescope if Snacks is not available

- **Configurable picker preference** - New `picker` config option to choose between pickers:
  - `"auto"` (default) - Uses Snacks if available, otherwise Telescope
  - `"snacks"` - Forces Snacks.nvim (with warning if not installed)
  - `"telescope"` - Forces Telescope (with warning if not installed)

### Changed

- Renamed internal module `telescope.lua` to `picker.lua` for better abstraction
- Updated `:ProjectNotesFind` command to support both Snacks and Telescope
- Floating window creation now prefers Snacks.nvim when available
- All documentation updated to reflect dual picker support

### Technical Details

- `lua/project-notes/picker.lua` - New unified picker module with auto-detection
- `lua/project-notes/ui.lua` - Enhanced to use `snacks.win` when available
- `lua/project-notes/init.lua` - Added `picker` configuration option

## [1.0.0] - Initial Release

### Added

- Per-project notes management based on Git repository
- SHA-256 hashing of remote origin URL for stable project identification
- Notes browser with floating window UI
- CRUD operations for notes (create, read, edit, delete)
- Automatic timestamping of notes
- Markdown preview in browser
- Telescope integration for fuzzy finding
- Configurable sort order (created, modified, title)
- Customizable keymaps
- Comprehensive documentation
