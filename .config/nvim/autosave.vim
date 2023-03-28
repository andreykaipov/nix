" automatically save if running :make or :GoBuild for example
set autowrite

" CursorHold(I) time in milliseconds
set updatetime=3000

" TODO - look into disabling history and swp files since we're autosaving
"
function! s:AutoSave()
    if @% == '' | return | endif             " no file name
    if &write == 0 | return | endif          " writes disabled (nvim -m)
    if &readonly == 1 | return | endif       " readonly (nvim -R)
    if &buftype != '' | return | endif       " :h buftype to read up on this
    if &modified == 0 | return | endif       " file wasn't modified

    " An update won't touch our file if we haven't changed it. Probably doesn't
    " matter since we already check for &modified above. We also temporarily
    " unset our undofile before updating, because an unnecessary "0 changes"
    " entry would be written into the undofile otherwise. Not sure why!
    "set noundofile | update | set undofile
    update

    " Issue a BufWritePost event for any autocmds that would listen for it. This
    " way we actual mimic a manual `:update`. For example, ALE listens for it to
    " run fixers on save.
    doautocmd BufWritePost " funky with folding

    echo "autosaved at " . strftime("%H:%M:%S")
endfunction

function! s:ToggleAutoSave()
    if exists('#AutoSave#CursorHold')
        echo 'Disabled autosave'
        augroup AutoSave
            autocmd!
        augroup END
    else
        echo "Enabled autosave"
        augroup AutoSave
            autocmd!
            autocmd CursorHold,CursorHoldI * :call s:AutoSave()
            "autocmd TextChanged,InsertLeave * :call s:AutoSave()
        augroup END
    endif
endfunction

command! ToggleAutoSave :call s:ToggleAutoSave()
nmap <leader>s :ToggleAutoSave<cr>
