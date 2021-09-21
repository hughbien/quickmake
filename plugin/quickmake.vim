if !exists("g:quickmake_terminal")
  let g:quickmake_height = 20

  function quickmake#is_created()
    return bufexists("quickmake") == 1
  endfunction

  function quickmake#is_visible()
    return bufwinnr("quickmake") != -1
  endfunction

  function quickmake#is_full()
    let quickmake_winnr = bufwinnr("quickmake")
    return winheight(quickmake_winnr) > g:quickmake_height
  endfunction

  function quickmake#create(full)
    if a:full
      exe "vert term"
    else
      exe "term"
      exe "resize " . g:quickmake_height
    end
    exe "file quickmake"
  endfunction

  function quickmake#destroy()
    exe "bdelete! quickmake"
  endfunction

  function quickmake#show(full = 0)
    if quickmake#is_visible()
      " no-op
    elseif quickmake#is_created() && a:full
      if winnr("$") > 1 " close last window if more than one
        execute winnr("$") . "wincmd c"
      endif
      exe "vert sbuffer quickmake"
    elseif quickmake#is_created()
      exe "sbuffer quickmake"
      exe "resize " . g:quickmake_height
    else
      call quickmake#create(a:full)
    endif
  endfunction

  function quickmake#hide()
    if quickmake#is_visible()
      let quickmake_winnr = bufwinnr("quickmake")
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

  nmap <C-W>t :call quickmake#toggle()<CR>
  tmap <C-W>t <C-W>:call quickmake#toggle()<CR>
  nmap <C-W>y :call quickmake#toggle_full()<CR>
  tmap <C-W>y <C-W>:call quickmake#toggle_full()<CR>
endif
