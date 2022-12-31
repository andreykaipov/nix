function! s:CheckShebang()
  if getline(1) =~ '^#!.*[/\\]bash' | set filetype=bash | return | endif
endfunction

augroup shebang
  au!
  autocmd BufNewFile,BufRead * :call s:CheckShebang()
augroup END
