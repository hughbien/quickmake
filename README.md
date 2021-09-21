# Quickmake

## Summary

A build drawer for Vim, for building/testing/linting/etc...

## Install

You can configure which `makeprgs` are available by language:

```vimscript
let g:quickmake_prgs = {}
let g:quickmake_prgs.default = ["make"]
let g:quickmake_prgs.ruby = ["rake", "rspec", "ruby"]
let g:quickmake_prgs.crystal = ["make", "crystal spec", "crystal run", "crystal build --release"]
let g:quickmake_prgs.javascript = ["npm run test", "npm run lint", "npm run lint:fix"]
```

It defaults to whatever `makeprg` is set to. I use this to detect a better default:

```vimscript
au filetype crystal,ruby,javascript,javascriptreact,typescript,typescriptreact call MPSetMake()

" autodetect and set makeprg, only once
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
    elseif &filetype == 'javascript' || &filetype == 'typescript' || &filetype == 'javascriptreact' || &filetype == 'typescriptreact'
      set makeprg=npm\ run\ test
    endif
  endif
endfunction
```

## Usage

## TODO

* shortcut to close/exit terminal process
* shortcut to run makeprg (and opens terminal if NOT open) with arg
* shortcut to run makeprg using last arg
* shortcut to set makeprg (via pre-configured list, for autotest/compile/lint/lintfix/custom/etc...)
* fix for `gf` to open in different window (if file is already open, use that window)
* setting for left/right-side quickmake
* setting for default height or full height
* setting for line numbers
* setting for makeprg per language
* setting for default makeprg per language or directory/file/glob exists
* instructions for install/usage

## License

Copyright Hugh Bien, <http://hughbien.com>. Released under BSD License, see LICENSE.md for more info.
