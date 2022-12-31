if ! isdirectory(printf('%s/autoload/plugs', root))
    finish
endif

let g:localvimrc_ask = 0
"let g:localvimrc_persistent = 0

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
" let g:deoplete#omni_patterns = {}
" let g:deoplete#omni_patterns.terraform = '[^ *\t"{=$]\w*'
" let g:deoplete#enable_at_startup = 1
" call deoplete#initialize()

" markdown
"
let g:vim_markdown_folding_disabled = 1

" colorscheme
"
colorscheme space_vim_theme
set background=dark

" lightline
"
"let g:lightline = {'colorscheme': 'one'}
"set noshowmode
"set laststatus=0
"set noruler

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

let g:tpipeline_autoembed = 0
let g:tpipeline_tabline = 0
let g:tpipeline_restore = 0
let g:tpipeline_clearstl = 1
let g:tpipeline_split = 1
let g:tpipeline_usepane = 1
let g:tpipeline_fillcentre = 1
"
"let g:tpipeline_statusline = '%!tpipeline#stl#line()'
"
let g:tpipeline_statusline = ''
let g:tpipeline_statusline .= '%F%h%w%m%r'
let g:tpipeline_statusline .= '%='
let g:tpipeline_statusline .= '[%{&fileformat} %{&fileencoding?&fileencoding:&encoding}]'
let g:tpipeline_statusline .= '%y'
