# QuickMake

## Summary

A build drawer for Vim. Features include:

* quickly toggle a terminal with a hotkey
* run make commands asynchronously, have output popup in terminal drawer
* use QuickMake's goto to edit file under cursor

![Quickmake Example](asset/quickmake.gif)

**This is a very alpha Vim Plugin. I actually don't recommend you use it.**

## Install

If you're using [vim-plug](https://github.com/junegunn/vim-plug), add this
line to your `~/.vimrc` plugin section:

    Plug 'hughbien/quickmake'

If you're using [Vundle](https://github.com/VundleVim/Vundle.vim), add this
line to your `~/.vimrc` plugin section:

    Plugin 'hughbien/quickmake'

If you're using [Pathogen](https://github.com/tpope/vim-pathogen), drop this
project under `~/.vim/bundle`.

## Setup

Set `makeprg` and `g:quickmake_prgs`:

```
" defaults to make
set makeprg=make

" defaults to ["make"]
let g:quickmake_prgs = ["make", "crystal spec", "crystal run", "crystal build --release"]
```

Here's an example function to autodetect which `makeprg` to use:

```vimscript
au filetype crystal,ruby call MPSetMake()

let g:MPSetMakeCalled = 0
function MPSetMake()
  if g:MPSetMakeCalled == 0
    let g:MPSetMakeCalled = 1
    if &filetype == 'crystal'
      if isdirectory('spec') || glob('*_spec.cr') != ''
        set makeprg=crystal\ spec
      elseif filereadable('Makefile')
        set makeprg=make
      else
        set makeprg=crystal\ run
      endif
      let g:quickmake_prgs = ["make", "crystal spec", "crystal run", "crystal build --release"]
    elseif &filetype == 'ruby'
      if isdirectory('spec') || glob('*_spec.rb') != ''
        set makeprg=rspec
      elseif filereadable('Makefile')
        set makeprg=make
      elseif filereadable('Rakefile')
        set makeprg=rake
      else
        set makeprg=ruby
      endif
      let g:quickmake_prgs = ["make", "rake", "rspec", "ruby"]
    endif
  endif
endfunction
```

You'll also want to setup some shortcuts to toggle the terminal and optionally use QuickMake's
goto:

```vimscript
" mappings to toggle a terminal
nmap <C-W>t :call quickmake#toggle()<CR>
tmap <C-W>t <C-W>:call quickmake#toggle()<CR>
nmap <C-W>y :call quickmake#toggle_full()<CR>
tmap <C-W>y <C-W>:call quickmake#toggle_full()<CR>
nmap <C-W>C :call quickmake#destroy()<CR>
tmap <C-W>C <C-W>:call quickmake#destroy()<CR>

" mappings to use QuickMake's goto, which go to primary/secondary windows
nmap gt :call quickmake#goto()<CR>
nmap gT :call quickmake#goto(1)<CR>
```

## Usage

With the settings above, I can use these shortcuts:

* `<C-w>t` to toggle a terminal open/closed
* `<C-w>y` to vertical split the terminal (or move it if it's currently horizontally split)
* `<C-w>C` to destroy the current terminal (not just hide it)

Available commands:

* `:QuickMake file1` runs the `makeprg` with `file1` as an argument
* `:QuickMakeRun ls` runs any random commands, without using `makeprg` as a prefix
* `:QuickMakeSet` without any arguments will list available `makeprg`s
* `:QuickMakeSet build` will set the makeprg. It only uses programs in your `g:quickmake_prgs` list.
  You can pass in a substring. Use `<tab>` for autocompletion.
* `:QuickMakeSetPrg anything` will set any arbitrary makeprg.

Use `%` as an argument for the current file. I like to hit `<tab>` to autocomplete, so I can run
the same make command over and over again even if I'm editing a different file.

When the terminal drawer is open with your `make` results, you can move the cursor to any file and
use `gt` or `gT` to go to it. The behavior is slightly different than Vim's `gf`:

1. if the file is already open, the cursor goes to that window instead of opening another window
2. it replaces the primary window's file (instead of opening it in QuickMake's window)
3. use `gT` to open it in the secondary window

## TODO

* clear function calls on toggles/destroy/goto

## License

Copyright Hugh Bien, <http://hughbien.com>. Released under BSD License, see LICENSE.md for more info.
