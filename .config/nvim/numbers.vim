" number column related things
"
" for hybrid numbers, ref: https://jeffkreeftmeijer.com/vim-number
"
function! s:ToggleNumbers()
    set number!
    set relativenumber!
    set numberwidth=1
    set invcursorline
    set signcolumn=number
endfunction

command! ToggleNumbers :call s:ToggleNumbers()
nmap <leader>n :ToggleNumbers<cr>

augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END
