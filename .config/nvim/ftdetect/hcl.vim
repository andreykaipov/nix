" just treat hcl files as tf files so we don't have to install a new plugin
"
augroup hcl
  au!
  autocmd BufNewFile,BufRead *.hcl set filetype=terraform
augroup END
