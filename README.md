# terminal.nvim

A floating terminal for Neovim.

## Features

- Toggle a floating terminal window with `<C-'>`
- Terminal state is preserved between toggles

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

- `<C-'>` — toggle the floating terminal (works in normal and terminal mode)
- `:TermFloat` — toggle the floating terminal via command
- `<C-w>` in terminal mode — switch to window navigation

## Development

### Running Tests

```bash
make test
```

Requires [busted](https://lunarmodules.github.io/busted/):

```bash
luarocks install busted
```
