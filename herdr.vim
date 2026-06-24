"" Plugin: herdr.vim
"" Author: Claude
"" Date: 24 Jun, 2026
"" Description: Send lines from vim to herdr panes (similar to tmux.vim)
"" Requirements: herdr installed and accessible in $PATH

"" A dictionary with opposite directions to herdr directions.
let s:opp_direction_dict = {'down': 'up', 'right': 'left', 'up': 'down', 'left': 'right'}

"" Return the opposite direction, given a herdr direction.
function! s:Opposite(direction)
  return get(s:opp_direction_dict, a:direction)
endfunction

function! s:GetCurrentLine()
  "" Return current line with newline appended.
  return getline('.') . "\n"
endfunction

function! s:GetVisualSelection()
  "" Copy current visual selection to register "a.
  keepjumps normal! gv"ay']
  "" Return the visual selection with newline appended.
  return @a . "\n"
endfunction

"" Get the pane ID in the given direction from current pane.
function! s:GetNeighborPane(direction)
  let result = system("herdr pane neighbor --direction " . a:direction . " --current 2>/dev/null")
  if v:shell_error != 0
    return ""
  endif
  "" Extract pane ID from JSON output (format: {"neighbor_pane_id":"..."})
  let match = matchstr(result, '"neighbor_pane_id":"\zs[^"]\+\ze"')
  return match
endfunction

"" Send `message` to herdr pane in `direction`.
function! s:Send(direction, message)
  let target_pane = s:GetNeighborPane(a:direction)

  if target_pane == ""
    echohl WarningMsg
    echo "herdr.vim: No pane found in direction: " . a:direction
    echohl None
    return
  endif

  "" Send the text to the target pane
  call system("herdr pane send-text " . shellescape(target_pane) . " " . shellescape(a:message))

  if v:shell_error != 0
    echohl ErrorMsg
    echo "herdr.vim: Failed to send text to pane: " . target_pane
    echohl None
  endif
endfunction

"" Send text in current line to herdr pane in `direction`.
function! s:SendLine(direction)
  call s:Send(a:direction, s:GetCurrentLine())
endfunction

"" Send text in current visual selection to herdr pane in `direction`.
function! s:SendVisual(direction)
  call s:Send(a:direction, s:GetVisualSelection())
endfunction

"" Start a REPL (julia/ipython/R/configured shell) in herdr pane below.
function! s:StartRepl()
  let ext = expand('%:e')
  "" Get the configured shell from $SHELL environment variable
  let default_shell = !empty($SHELL) ? $SHELL : 'bash'
  let cmd = get({
    \'R': 'R',
    \'jl': 'julia',
    \'py': 'ipython --no-autoindent'
  \}, ext, default_shell)

  "" Get current pane
  let current_result = system("herdr pane current --current 2>/dev/null")
  let current_pane = matchstr(current_result, '"pane_id":"\zs[^"]\+\ze"')

  if current_pane == ""
    echohl ErrorMsg
    echo "herdr.vim: Failed to get current pane"
    echohl None
    return
  endif

  "" Split pane down and run the REPL
  call system("herdr pane split " . shellescape(current_pane) . " --direction down --ratio 0.34 --focus")

  "" Small delay to let pane be created
  sleep 100m

  "" Get the new pane ID (should be below)
  let new_pane = s:GetNeighborPane('down')
  if new_pane != ""
    "" Send the command to start REPL
    call system("herdr pane send-text " . shellescape(new_pane) . " " . shellescape(cmd . "\n"))
    "" Focus back to original pane
    call system("herdr pane focus --direction up")
  endif
endfunction

"" Source a file into herdr pane (REPL or BASH) below.
function! s:SourceFile()
  let ext = expand('%:e')
  let filename = expand('%:p')
  let cmd = ''

  let cmd = get({
    \'R': 'source("' . filename . '")',
    \'jl': 'include("' . filename . '")',
    \'py': 'exec(open("' . filename . '").read())',
    \'sh': 'source ' . filename,
    \'kt': 'load: ' . filename,
    \'scala': 'load: ' . filename,
  \}, ext, '')

  if cmd == ''
    "" If no source command, send entire file line by line
    let save_pos = getpos('.')
    %call s:SendLine('down')
    call setpos('.', save_pos)
  else
    call s:Send('down', cmd . "\n")
  endif
endfunction

"" Plugin mappings.
nnoremap <Plug>HerdrStartRepl :<C-U> call <SID>StartRepl()<CR>
nnoremap <silent> <Plug>HerdrSourceFile :<C-U> call <SID>SourceFile()<CR>
nnoremap <silent> <Plug>HerdrSendLineDown :<C-U> call <SID>SendLine("down")<CR>
nnoremap <silent> <Plug>HerdrSendLineRight :<C-U> call <SID>SendLine("right")<CR>
nnoremap <silent> <Plug>HerdrSendLineUp :<C-U> call <SID>SendLine("up")<CR>
nnoremap <silent> <Plug>HerdrSendLineLeft :<C-U> call <SID>SendLine("left")<CR>
xnoremap <silent> <Plug>HerdrSendVisualDown :<C-U> call <SID>SendVisual("down")<CR>
xnoremap <silent> <Plug>HerdrSendVisualRight :<C-U> call <SID>SendVisual("right")<CR>
xnoremap <silent> <Plug>HerdrSendVisualUp :<C-U> call <SID>SendVisual("up")<CR>
xnoremap <silent> <Plug>HerdrSendVisualLeft :<C-U> call <SID>SendVisual("left")<CR>

"" Default key bindings (matching tmux.vim behavior).
if !exists('g:herdr_default_bindings') || g:herdr_default_bindings
  nmap <C-k> <Plug>HerdrStartRepl
  nmap <C-h> <Plug>HerdrSourceFile
  nmap <C-j> <Plug>HerdrSendLineDown
  nmap <C-l> <Plug>HerdrSendLineRight
  xmap <C-j> <Plug>HerdrSendVisualDown
  xmap <C-l> <Plug>HerdrSendVisualRight
endif
