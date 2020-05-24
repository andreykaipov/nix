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
    augroup _
        au!
        autocmd VimEnter * PlugInstall --sync
    augroup END
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

" double tap v to select the entire line
"
nmap vv <S-v>

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
set textwidth=80
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

" Customize cursor. See :help guicursor for mode-list.
" TODO - experiment with removing mode in status line as it's evident what mode
" we're in based on the cursor. The following settings are pretty much the
" default, but instead of a block in normal mode, we use a solid bar, and
" instead of a solid bar in insert mode, we make it blink. Blink times don't
" seem to work on Windows terminal or a variety of Linux terminals, but we'll
" leave them in.
"
set guicursor=n-v-c:ver25
            \,i-ci-ve:ver25-blinkwait700-blinkoff400-blinkon250
            \,r-cr-o:hor20

" override any colorscheme with our custom highlights that are superior
" anywhere. don't @ me. use :XtermColorTable to view available colors. see :help
" highlight-groups for available highlight groups.
"
function! SetCustomHighlights()
    highlight ColorColumn                            ctermbg=155
    highlight CursorLine                             ctermbg=233
    highlight CursorLineNr            ctermfg=yellow ctermbg=233
    highlight Normal                  ctermfg=252    ctermbg=none
    highlight MatchParen   cterm=bold ctermfg=208    ctermbg=233
    " highlight highlight-group :cterm=NONE ctermbg=NONE ctermfg=NONE gui=NONE guibg=NONE guifg=NONE
endfunction

exec printf('source %s/numbers.vim', root)
exec printf('source %s/autosave.vim', root)

" When formatting via gq, vim will try to add two spaces after periods. This is
" not the late 19th century, and is a silly default.
set nojoinspaces

" to be used in autocmd events
" TODO - take out ToggleAutoSave and create autocmds on FileTypes to enable it
" on specific filetypes only. See autosave.vim for reasoning.
"
function s:OnOpenFile()
    " we use an autocmd to set global formatoptions because underlying plugins
    " may overwrite this value. see :h fo-table
    "
    " c - autowrap comments using the textwidth, inserting the comment leader
    " r - automatically insert comment leader after hitting <cr> during Insert
    " o - automatically insert comment leader after hitting o or O during Normal
    " q - allow comment formatting via gq
    " maybe w - line ending in non-whitespace character will not be
    " maybe a - auotmatic formatting of paragraphs (only for comments with c)
    " 1 - don't break lines after one-letter words, if possible
    " j - remove comment leaders when joining lines, if possible
    "
    set formatoptions=croq1j

    " better to put in an autocmd rather than directly calling it, since
    " re-sourcing $MYVIMRC will not trigger our toggles this way
    "
    ToggleNumbers
    ToggleAutoSave
endfunction

augroup init
    au!

    autocmd BufNewFile,BufRead * :call s:OnOpenFile()

    autocmd ColorScheme * :call SetCustomHighlights()

    " go back to last position after closing (see :help restore-cursor)
    "
    autocmd BufRead *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ |   exe "normal! g`\""
        \ | endif
augroup END
