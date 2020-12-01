" don't sleuth on Python files
let b:sleuth_automatic = 0

" configure expanding of tabs for various file types
set expandtab           " enter spaces when tab is pressed
set textwidth=120       " break lines when line length increases
set tabstop=4           " use 4 spaces to represent tab
set softtabstop=4
set shiftwidth=4        " number of spaces to use for auto indent
set autoindent          " copy indent from current line when starting a new line

" make backspaces more powerfull
set backspace=indent,eol,start

set ruler                           " show line and column number
"syntax on               " syntax highlighting
set showcmd             " show (partial) command in status line
