if !exists("g:quickmake_terminal")
  let g:quickmake_height = 20
  let g:quickmake_bufname = "__quickmake__"
  let g:quickmake_position = "right"
  let g:quickmake_prgs = ["make", "crystal spec", "crystal run", "crystal build --release"]

  function quickmake#is_created()
    return bufexists(g:quickmake_bufname) == 1
  endfunction

  function quickmake#is_visible()
    return bufwinnr(g:quickmake_bufname) != -1
  endfunction

  function quickmake#is_full()
    let quickmake_winnr = bufwinnr(g:quickmake_bufname)
    return winheight(quickmake_winnr) > g:quickmake_height
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
    if a:full
      let term = "vert term"
    else
      let term = "term"
    endif

    if a:command != ""
      exe term " " . a:command
    else
      exe term
    endif

    if a:full == 0
      exe "resize " . g:quickmake_height
    endif

    exe "file " . g:quickmake_bufname
    exe "set nonu"
    exe "set buftype=nofile"
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

  function quickmake#make(...)
    let full = quickmake#is_full()
    if quickmake#is_created()
      call quickmake#destroy()
    endif

    call quickmake#create(full, &makeprg . " " . join(a:000))
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

  nmap <C-W>t :call quickmake#toggle()<CR>
  tmap <C-W>t <C-W>:call quickmake#toggle()<CR>
  nmap <C-W>y :call quickmake#toggle_full()<CR>
  tmap <C-W>y <C-W>:call quickmake#toggle_full()<CR>
  nmap <C-W>C :call quickmake#destroy()<CR>
  tmap <C-W>C <C-W>:call quickmake#destroy()<CR>

  command! -nargs=* QuickMake call quickmake#make(<f-args>)
  command! QuickMakeList call quickmake#list_prgs()
  command! -nargs=* QuickMakeSet call quickmake#set_prg(<f-args>)
endif
