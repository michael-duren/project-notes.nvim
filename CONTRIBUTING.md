# Contributing to Project Notes

Thank you for your interest in contributing to Project Notes!

## Development Setup

1. Clone the repository:
```bash
git clone https://github.com/yourname/project-notes.nvim
cd project-notes.nvim
```

2. Create a test Neovim configuration that loads the plugin from your local directory:

```lua
-- In ~/.config/nvim/init.lua or a separate test config
vim.opt.rtp:prepend("~/path/to/project-notes.nvim")

require("project-notes").setup()
```

## Testing

To test the plugin:

1. Open Neovim in any Git repository
2. Run `:ProjectNotes` to open the browser
3. Press `n` to create a new note
4. Test editing, deleting, and finding notes

## Code Style

- Use 2 spaces for indentation
- Follow the existing code style
- Add comments for complex logic
- Keep functions focused and modular

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Bug Reports

When reporting bugs, please include:

- Neovim version (`nvim --version`)
- Operating system
- Steps to reproduce
- Expected vs actual behavior
- Error messages (if any)

## Feature Requests

Feature requests are welcome! Please:

- Check existing issues first
- Describe the use case
- Explain why it would be useful
- Consider contributing the implementation

## Questions?

Feel free to open an issue for questions or discussions.
