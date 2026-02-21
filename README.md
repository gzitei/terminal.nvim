# terminal.nvim

A floating terminal for Neovim.

## Features

- Toggle a floating terminal window with `<C-t>` (configurable)
- Terminal state is preserved between toggles
- Configurable size, position, and keymap

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "gzitei/terminal.nvim",
  config = function()
    require("terminal").setup()
  end,
}
```

## Usage

- `<C-t>` — toggle the floating terminal (works in normal and terminal mode)
- `:TermFloat` — toggle the floating terminal via command
- `<C-w>` in terminal mode — switch to window navigation

## Configuration

All options are optional. The defaults match the behaviour below:

```lua
require("terminal").setup({
  keymap = "<C-t>",  -- key to toggle the terminal
  width  = 0.8,      -- window width  as a fraction of the editor (0–1)
  height = 0.4,      -- window height as a fraction of the editor (0–1)
  row    = 1.0,      -- vertical anchor   (0 = top, 1 = bottom)
  col    = 0.5,      -- horizontal anchor (0 = left, 0.5 = center, 1 = right)
})
```

## Development

### Running Tests

```bash
make test
```

Requires [busted](https://lunarmodules.github.io/busted/):

```bash
luarocks install busted
```
