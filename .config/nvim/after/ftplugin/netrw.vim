" netrw overrides C-l that's used by vim-tmux-navigator
" and set in after/init.vim, so we re-override it.
"
" https://github.com/christoomey/vim-tmux-navigator/issues/189#issuecomment-792555345
"
" for debugging see :verbose map <C-l>
"
nnoremap <silent> <buffer> <C-l> :TmuxNavigateRight<cr>
