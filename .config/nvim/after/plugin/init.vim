if ! isdirectory(printf('%s/autoload/plugs', root))
    finish
endif

" colorscheme junk
"
colorscheme space_vim_theme
set background=dark

" lightline junk
"
let g:lightline = {'colorscheme': 'one'}
set noshowmode
