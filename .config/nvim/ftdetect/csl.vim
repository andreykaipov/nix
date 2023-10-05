" treat csl as hcl files so nicer syntax colors
augroup csl
  au!
  autocmd BufNewFile,BufRead *.csl set filetype=hcl
augroup END
