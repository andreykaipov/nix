"

function! StartsWith(longer, shorter) abort
    return a:longer[0:len(a:shorter)-1] ==# a:shorter
endfunction

function! FileIsInDirectory(directory) abort
    let l:fname = expand('%:p')
    return StartsWith(l:fname, a:directory)
endfunction
