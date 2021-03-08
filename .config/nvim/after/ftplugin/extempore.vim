" Remap default timburgess/extempore.vim mappings
nmap <leader>w
"nmap <leader>p :ExtemporeSendEnclosingBlock()<cr>
"nmap 'w :ExtemporeSendEnclosingBlock()<cr>
nmap ;w :ExtemporeSendEnclosingBlock()<cr>

autocmd VimEnter *.xtm :ExtemporeOpenConnection()
