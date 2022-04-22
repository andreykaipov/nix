" detects filetypes based on shebang line
"
" don't have to import this file anywhere; vim just recognizes it
"
" docs: https://neovim.io/doc/user/usr_43.html
" search `RECOGNIZING BY CONTENTS`

if did_filetype()
    finish
endif

if getline(1) =~ '^#!.*[/\\]bash\>'
    set filetype=bash
endif
