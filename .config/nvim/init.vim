let root = has('neovim') ? stdpath('config') : expand('~/.config/nvim')
let mapleader = ','
let is_posix = 1 " in the 21st century, no machine should have a non-POSIX /bin/sh

" install Vim Plug for Neovim
" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
"
let vimplug_local  = printf('%s/autoload/plug.vim', root)
let vimplug_remote = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

if !filereadable(vimplug_local)
    if !executable('curl')
        echoerr "You're missing curl..."
        sleep 1000m
        execute 'q!'
    endif

    echo 'Installing Vim-Plug...'
    silent exec printf('!curl -sLo %s %s --create-dirs', vimplug_local, vimplug_remote)
    autocmd startup VimEnter * PlugInstall --sync
endif

" install plugins
"
call plug#begin(printf('%s/autoload/plugs', root))
exec printf('source %s/plugs.vim', root)
call plug#end()

" preserve history after closing
"
if has('persistent_undo')
    set undofile
    exec printf('set undodir=%s/tmp/undo//', root)
endif

" sets backup and swap dirs
"
set backup
exec printf('set backupdir=%s/tmp/bak//', root)
exec printf('set directory=%s/tmp/swp//', root)

" sets the system register (+) as the default one for yanking and pasting junk
"
set clipboard=unnamedplus

" smart searches
"
set ignorecase
set smartcase

" highlight searches, keep them centered when finding the next hit, and easily
" clear them out
"
set hlsearch
nmap n nzz
nmap N Nzz
nmap * *zz
nmap # #zz
nmap <leader><cr> :nohlsearch<cr>

" make it easier to switch Vim windows
"
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l
nmap <C-h> <C-w>h

" make Vim behave similarly when using terminal keyboard shortcuts in command
" mode (see :help tcsh-style). strangely, <C-u> works already.
"
cmap <C-a> <Home>
cmap <C-e> <End>
cmap <C-f> <Right>
cmap <C-b> <Left>

" maintain visual block selection after > or <
"
vmap < <gv
vmap > >gv

" allow moving entire visual block down or up
"
vmap J :m '>+1<cr>gv=gv
vmap K :m '<-2<cr>gv=gv

" show 81 char line. ideally our code won't go past it.
" because of this, we don't need to wrap lines.
"
set colorcolumn=81
set nowrap

" scroll offset sets the number of context lines we see whenever we scroll
"
set scrolloff=20

" show the following special chars in list mode
"
scriptencoding=utf-8
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
nmap <leader>l :set invlist<cr>

" ToggleNumber toggles some number stuff and the cursorline
"
function! s:ToggleNumbers()
    set invnumber
    set invrelativenumber
    set numberwidth=5
    set invcursorline
endfunction

command! ToggleNumbers :call s:ToggleNumbers()
nmap <leader>n :ToggleNumbers<cr>

" use :XtermColorTable to view available colors.
" see :help highlight-groups for available highlight groups.
"
function! SetCustomHighlights()
    highlight ColorColumn                            ctermbg=155
    highlight CursorLine                             ctermbg=black
    highlight CursorLineNr            ctermfg=yellow ctermbg=black
    highlight Normal                  ctermfg=252
    highlight MatchParen   cterm=bold ctermfg=208    ctermbg=233
    " highlight highlight-group :cterm=NONE ctermbg=NONE ctermfg=NONE gui=NONE guibg=NONE guifg=NONE
endfunction

augroup init
    au!

    " better to put this in an autocmd rather than directly calling it, e.g.
    " sourcing $VIMRC will not toggle numbers this way
    autocmd BufReadPost * ToggleNumbers

    " override any colorscheme with our custom highlights that are superior
    " anywhere, don't @ me
    "
    autocmd ColorScheme * call SetCustomHighlights()

    " go back to last position after closing (see :help restore-cursor)
    "
    autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ |   exe "normal! g`\""
        \ | endif
augroup END
