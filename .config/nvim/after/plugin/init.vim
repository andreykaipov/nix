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
let g:ale_sign_error = ' ●'
let g:ale_sign_warning = ' .'

" deoplete
" https://github.com/juliosueiras/vim-terraform-completion#deoplete-config
let g:deoplete#omni_patterns = {}
let g:deoplete#omni_patterns.terraform = '[^ *\t"{=$]\w*'
let g:deoplete#enable_at_startup = 1
call deoplete#initialize()

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
" lilydjwg's colorizer, maybe don't get rid of it just yet
"let g:colorizer_maxlines = 1000
"let g:colorizer_fgcontrast = 0
"let g:colorizer_no_map = 0

" I want the verb at front of the command
command! ToggleColor :ColorToggle
nmap <leader>c :ToggleColor<cr>
