set title

" Color scheme.
set t_Co=256
set background=dark
"colorscheme stonewashed-256
colorscheme slate
"colo elflord
"colo darkblue
"colo delek

set number             " Display line numbers.
set numberwidth=3

set tabstop=4          " Take care of tab and space nonsense.
set softtabstop=4
set shiftwidth=4
set expandtab

set showmatch          " Show matching parentheses.
set incsearch          " Search as you type.
set ignorecase
set smartcase          " Only case-senstive if search term is all caps
set hlsearch           " Highlight search terms.

" Make terminal shortcuts behave similarly when using VIM commands.
cnoremap <C-A> <Home>
cnoremap <C-E> <End>

" :noh clears the currently highlighted search. Don't map to <Esc>!
nnoremap <C-L> :noh<Return>

" Move down and up by rows instead of by lines.
nmap j gj
nmap k gk

set autoindent            " Auto indent code.
filetype plugin indent on " Detect syntax for filetypes.

" Have Vim jump to the last position when repoening a file.
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

