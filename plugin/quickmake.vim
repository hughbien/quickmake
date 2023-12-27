if !exists("g:quickmake")
  let g:quickmake = 1

  if !exists("g:quickmake_height")
    let g:quickmake_height = 20
  endif
  if !exists("g:quickmake_bufname")
    let g:quickmake_bufname = "!make"
  endif
  if !exists("g:quickmake_position")
    let g:quickmake_position = "right"
  endif
  if !exists("g:quickmake_prgs")
    let g:quickmake_prgs = ["make"]
  endif
  if !exists("g:quickmake_shell")
    let g:quickmake_shell = "bash -c"
  endif
  if !exists("g:quickmake_goto_prefix")
    let g:quickmake_goto_prefix = ""
  endif
  if !exists("g:quickmake_nu")
    let g:quickmake_nu = 0
  endif

  function quickmake#is_created()
    return bufexists(g:quickmake_bufname) == 1
  endfunction

  function quickmake#is_visible()
    return bufwinnr(g:quickmake_bufname) != -1
  endfunction

  function quickmake#is_full()
    let quickmake_winnr = bufwinnr(g:quickmake_bufname)
    let session_height = &lines - &cmdheight - 1 " 1 for status
    return winheight(quickmake_winnr) >= session_height
  endfunction

  function quickmake#close_last_window()
    if winnr("$") > 1 " close last window if more than one
      exe winnr("$") . "wincmd c"
    endif
  endfunction

  function quickmake#move_to_corner()
    if g:quickmake_position == "left"
      let move_char = "h"
    else
      let move_char = "l"
    endif

    exe winnr("$") . "wincmd " . move_char
    exe winnr("$") . "wincmd j"
  endfunction

  function quickmake#create(full = 0, command = "")
    if has('nvim')
      if a:full
        let term = "vsplit | term"
      else
        let term = "split | term"
      endif
    else
      if a:full
        let term = "vert term"
      else
        let term = "term"
      endif
    endif

    if a:command != "" && g:quickmake_shell != 0
      exe term . " " . g:quickmake_shell . " \"" . a:command . "\""
    elseif a:command != ""
      exe term . " " . a:command
    else
      exe term
      if has('nvim')
        startinsert
      endif
    endif

    if a:full == 0
      exe "resize " . g:quickmake_height
    endif

    exe "file " . g:quickmake_bufname
    " exe "set buftype=nofile"

    if g:quickmake_nu
      exe "set nu"
    else
      exe "set nonu"
    endif

    if a:command != ""
      exe "setlocal statusline=" . substitute(a:command, " ", "\\\\ ", "g")
      exe "normal :<BS>"
    endif
  endfunction

  function quickmake#destroy()
    exe "bwipeout! " . g:quickmake_bufname
  endfunction

  function quickmake#show(full = 0)
    if quickmake#is_visible()
      " no-op
    else
      if a:full
        call quickmake#close_last_window()
      endif
      call quickmake#move_to_corner()

      if quickmake#is_created() && a:full
        exe "vert sbuffer " . g:quickmake_bufname
      elseif quickmake#is_created()
        exe "sbuffer " . g:quickmake_bufname
        exe "resize " . g:quickmake_height
      else
        call quickmake#create(a:full)
      endif
    endif
  endfunction

  function quickmake#hide()
    if quickmake#is_visible()
      let quickmake_winnr = bufwinnr(g:quickmake_bufname)
      exe "close " . quickmake_winnr
    endif
  endfunction

  function quickmake#toggle()
    if quickmake#is_visible()
      call quickmake#hide()
    else
      call quickmake#show()
    endif
  endfunction

  function quickmake#toggle_full()
    if quickmake#is_visible() && quickmake#is_full()
      call quickmake#hide()
      return
    endif

    if quickmake#is_visible()
      call quickmake#hide()
    endif
    call quickmake#show(1)
  endfunction

  function quickmake#run(...)
    let full = quickmake#is_full()
    if quickmake#is_created()
      call quickmake#destroy()
    endif

    " expand command before moving to corner, or % will be incorrect
    let parts = []
    for part in a:000
      call add(parts, expand(part))
    endfor

    call quickmake#move_to_corner()
    call quickmake#create(full, join(parts))
  endfunction

  function quickmake#make(...)
    call call("quickmake#run", [&makeprg] + a:000)
  endfunction

  function quickmake#list_prgs()
    let output = ""
    let index = 0

    if index(g:quickmake_prgs, &makeprg) == -1
      echo "makeprg=" . &makeprg
    endif

    for prg in g:quickmake_prgs
      if &makeprg == prg
        let prefix = "> "
      else
        let prefix = "  "
      endif
      let output .= prefix . prg . (index == len(g:quickmake_prgs) - 1 ? "" : "\n")
      let index += 1
    endfor
    echo output
  endfunction

  function quickmake#set_prg(...)
    let matcher = join(a:000)

    if matcher == ""
      call quickmake#list_prgs()
      return
    endif

    for prg in g:quickmake_prgs
      if stridx(prg, matcher) != -1
        exe "set makeprg=" . substitute(prg, " ", "\\\\ ", "g")
        call quickmake#list_prgs()
        return
      endif
    endfor

    echo "No match found for: " . matcher
    call quickmake#list_prgs()
  endfunction

  function quickmake#complete_prg(word, command, position)
    let matcher = join(split(a:command)[1:])
    let matches = []

    " only complete end of phrase, we'll need to remove some words at start
    let remove_words = len(split(matcher)) - 1
    if remove_words < 0
      let remove_words = 0
    endif

    " no support for cursor in middle of command
    if a:position < len(a:command)
      return matches
    endif

    for prg in g:quickmake_prgs
      if stridx(prg, matcher) != -1
        let prg_with_removed_words = join(split(prg)[remove_words:])
        call add(matches, prg_with_removed_words)
      endif
    endfor
    return matches
  endfunction

  function quickmake#goto_window(secondary = 0)
    let is_quickmake = buffer_name() == g:quickmake_bufname
    let is_quickfix = getwininfo(win_getid())[0]['quickfix'] == 1
    let win_height = winheight(win_getid())
    let num_windows = winnr("$")

    if is_quickmake || is_quickfix
      if a:secondary == 0
        exe "1wincmd w"
      elseif num_windows >= 3
        exe "2wincmd w"
      elseif num_windows == 1
        exe "vsplit"
        exe "1wincmd w"
      elseif is_quickfix
        exe "cclose"
        exe "vsplit"
        exe "copen " . win_height
        exe "2wincmd w"
      else
        call quickmake#hide()
        exe "vsplit"
        call quickmake#show()
        exe "2wincmd w"
      endif
    else
      if a:secondary == 0
        exe "1wincmd w"
      elseif num_windows == 1
        exe "vsplit"
        exe "2wincmd w"
      else
        exe "2wincmd w"
      endif
    endif
  endfunction

  function quickmake#goto(secondary = 0)
    let file = expand("<cfile>")
    let parts = split(expand("<cWORD>"), "[:|]")
    let line_no = 0
    let col_no = 0

    if g:quickmake_goto_prefix != ""
      let file = substitute(file, "^" . g:quickmake_goto_prefix, "", "")
    endif

    if len(parts) > 1
      let line_no = substitute(parts[1], "\\D", "", "g")
    endif

    if len(parts) > 2
      let col_no = substitute(parts[2], "\\D", "", "g")
    endif

    let buffername = bufname(file)
    if buffername == ""
      call quickmake#goto_window(a:secondary)
      exe "edit " . file
    endif

    let winnum = bufwinnr(buffername)
    if winnum == -1
      call quickmake#goto_window(a:secondary)
      exe "b " . buffername
    endif

    if winnum > 0
      exe winnum . "wincmd w"
    endif

    if line_no
      exe "normal " . line_no . "G"
    endif

    if col_no
      exe "normal " . col_no . "|"
    endif
  endfunction

  command! -nargs=* -complete=file QuickMake call quickmake#make(<f-args>)
  command! -nargs=* -complete=file QuickMakeRun call quickmake#run(<f-args>)
  command! -nargs=* -complete=customlist,quickmake#complete_prg QuickMakeSet call quickmake#set_prg(<f-args>)
endif
