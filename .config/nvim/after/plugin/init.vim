if ! isdirectory(printf('%s/autoload/plugs', root))
    finish
endif

" lightline has to go before colorscheme to get colors right
"let g:lightline = {'colorscheme': 'simpleblack'}
"set noshowmode
"set laststatus=2
"set noruler

colorscheme space_vim_theme
set background=dark
augroup auto_colorize
    autocmd!
    autocmd
          \ BufNewFile,BufRead,BufEnter,BufLeave,WinEnter,WinLeave,WinNew
          \ *.js,*.css,*.scss,*.sass,*.toml,*.yml,*.yaml
          \ ColorHighlight
augroup END

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
" color crap
"

"let g:tpipeline_embedopts = ['status-justify absolute-centre']
let g:tpipeline_autoembed = 0
let g:tpipeline_tabline = 0
let g:tpipeline_restore = 0
let g:tpipeline_focuslost = 0
let g:tpipeline_fillcentre = 0
let g:tpipeline_clearstl = 1
let g:tpipeline_split = 1
let g:tpipeline_usepane = 1
let g:tpipeline_size = 500

let g:tpipeline_statusline = '#[bg=default]'
let g:tpipeline_statusline .= ''
let g:tpipeline_statusline .= '#[fg=brightcyan]%t%h%w%m%r ' " %F
let g:tpipeline_statusline .= '#[fg=orange](%l,%c%V) %P '
let g:tpipeline_statusline .= '%='
let g:tpipeline_statusline .= '#[fg=brightmagenta]%y'
let g:tpipeline_statusline .= '#[fg=pink][%{&fileformat} %{&fileencoding?&fileencoding:&encoding}]'

" for https://github.com/christoomey/vim-tmux-navigator
let g:tmux_navigator_no_mappings = 1
let g:tmux_navigator_disable_when_zoomed = 0
noremap <silent> <M-h> :<C-U>TmuxNavigateLeft<cr>
noremap <silent> <M-j> :<C-U>TmuxNavigateDown<cr>
noremap <silent> <M-k> :<C-U>TmuxNavigateUp<cr>
noremap <silent> <M-l> :<C-U>TmuxNavigateRight<cr> " overwritten by netrw, fixed in ftplugin
noremap <silent> <M-i> :<C-U>TmuxNavigatePrevious<cr>

" netrw stuff
"
let g:netrw_liststyle = 0    " one file per line (3 for tree, but this is better for spamming - to stay in git repo)
let g:netrw_netrw_banner = 0 " vinegar hides the banner by default anyway (I to toggle)
let g:netrw_browse_split = 0 " reuse window when opening file
let g:netrw_hide = 0         " show all files
"
" for https://github.com/tpope/vim-vinegar
" it's great, but vinegar's - will keep going up until it hits /
" this overrides that behavior to stop at the git repo root
"
function! s:VinegarUpModified()
    if exists('b:netrw_curdir') && isdirectory(b:netrw_curdir . "/.git")
        return
    endif
    execute "normal \<Plug>VinegarUp"
endfunction
command! VinegarUpModified :call s:VinegarUpModified()
autocmd FileType netrw map <silent> <buffer> - :VinegarUpModified<cr>

" ale
"
let g:ale_disable_lsp = 1
let g:ale_fix_on_save = 1
let g:ale_fixers = {
    \   '*': ['remove_trailing_lines', 'trim_whitespace'],
    \ }
let g:ale_linters = {
    \ 'sh': ['language_server'],
    \ }
let g:ale_sign_error = ' ●'
let g:ale_sign_warning = ' .'

" markdown
"
let g:vim_markdown_folding_disabled = 1


"let g:localvimrc_whitelist = [
"    \ expand('~/gh/ninesapp')
"    \]


"
" deoplete
" https://github.com/juliosueiras/vim-terraform-completion#deoplete-config
" let g:deoplete#omni_patterns = {}
" let g:deoplete#omni_patterns.terraform = '[^ *\t"{=$]\w*'
" let g:deoplete#enable_at_startup = 1
" call deoplete#initialize()
