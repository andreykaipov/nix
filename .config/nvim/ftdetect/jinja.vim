augroup filetypedetect
  autocmd BufNewFile,BufRead *.html.j{2,inja}       set filetype=html
  autocmd BufNewFile,BufRead *.{yml,yaml}.j{2,inja} set filetype=yaml
augroup END
