" can't find a good jinja plugin. honestly it's much easier to just let Vim
" treat the template as the type it's supposed to be.
"
augroup jinjadetect
  au!
  autocmd BufNewFile,BufRead *.html.j{2,inja}       set filetype=html
  autocmd BufNewFile,BufRead *.{yml,yaml}.j{2,inja} set filetype=yaml
augroup END
