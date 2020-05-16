" in addition to some number stuff, we toggle the cursorline too
"
function! s:ToggleNumbers()
    set invnumber
    set invrelativenumber
    set numberwidth=5
    set invcursorline
endfunction

command! ToggleNumbers :call s:ToggleNumbers()
nmap <leader>n :ToggleNumbers<cr>
