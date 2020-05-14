if ! isdirectory(printf('%s/autoload/plugs', root))
    finish
endif

" ale
"
let g:ale_disable_lsp = 1
let g:ale_fix_on_save = 1
let g:ale_fixers = {
    \   '*': ['remove_trailing_lines', 'trim_whitespace'],
    \ }

" markdown
"
let g:vim_markdown_folding_disabled = 1

" colorscheme
"
colorscheme space_vim_theme
set background=dark

" lightline
"
let g:lightline = {'colorscheme': 'one'}
set noshowmode

" don't colorize larger files
" https://github.com/lilydjwg/colorizer#known-issues
"
let g:colorizer_maxlines = 1000
let g:colorizer_fgcontrast = 0
let g:colorizer_no_map = 0
nmap <leader>c :ColorToggle<cr>
