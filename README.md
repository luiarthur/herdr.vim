# herdr.vim

## Dependencies
- `NeoVIM 0.5+`, `vim7.4+`, `vim8`, or `vim9`
- `herdr>=0.7.1`

# Installation
If using the plugin manager `plug.vim` add `Plug luiarthur/herdr.vim` to the
correct location. Similar for other vim plugin managers. If not using a plugin
manager, just copy `plugin/herdr.vim` to `~/.vim/plugin/` (for vim users). If
using NeoVIM, add the following to `~/.config/nvim/init.lua`:

```lua
vim.pack.add({
  "https://github.com/luiarthur/herdr.vim"
})
```

## Usage
1. Start a `herdr` session.
2. Open a file in NeoVIM / VIM.
3. In `Normal` mode, type `Ctrl-k`. If the file extension is of a supported
   language (see below), then an appropriate REPL will be spawned in a `herdr`
   pane below. If the language is not supported, or if you prefer a different
   REPL, start a terminal in a `herdr` pane below. E.g., using `<Ctrl-b> "`. By
   default, if a language is not supported, `Ctrl-k` will simply open a new
   pane and enter a BASH terminal.
3. Navigation (see below)

## Navigation

From a vim buffer (file) within `herdr`, you can do the following in `Normal`
mode.

Action                                   | Command
---------------------------------------- |------------------------------------------------ 
Start REPL (see above)                   |`Ctrl-k`
Source the file (language is supported)  |`Ctrl-h` anywhere in file
Send current line to REPL below          |`Ctrl-j` on a line
Send current line to REPL on right       |`Ctrl-l` on a line
Send the selected lines to REPL below    |`Ctrl-j` on a visual selection of multiple lines 
Send the selected lines to REPL on right |`Ctrl-l` on a visual selection of multiple lines 

Note that the REPL (and buffers) will be in `Normal` mode, but lines from the
buffer will be executed in the REPLs.

The default key-bindings can be remapped. For example, the default bindings are
defined as follows:

Action                                   | Default key-binding
---------------------------------------- |------------------------------------------------ 
Start REPL                               | `nmap <C-k> <Plug>TmuxStartRepl<CR>`
Source the file                          | `nmap <C-h> <Plug>TmuxSourceFile<CR>`
Send current line to REPL below          | `nmap <C-j> <Plug>TmuxSendLineDown<CR>`
Send current line to REPL on right       | `nmap <C-l> <Plug>TmuxSendLineRight<CR>`
Send the selected lines to REPL below    | `xmap <C-j> <Plug>TmuxSendVisualDown`
Send the selected lines to REPL on right | `xmap <C-l> <Plug>TmuxSendVisualRight`

Default key bindings will be used if either `let g:herdr_default_bindings = 1`
is invoked in `init.vim` OR `g:herdr_default_bindings` is not defined.

## Supported Languages
- Julia (`*.jl`)
- Python (`*.py`)
- R (`*.R`)
