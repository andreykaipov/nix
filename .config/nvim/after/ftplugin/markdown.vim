set textwidth=0
set wrapmargin=0
set wrap      " soft wrap with Goyo is beautiful
set linebreak " breaks at words
"set showbreak=++
"set nocursorline
"set nocursorcolumn

let g:sentencer_textwidth = -1
set formatexpr=sentencer#Format()
set formatoptions+=n " better line wrapping sentences in list items
let &formatlistpat='^\s*\d\+\.\s\+\|^\s*[-*+]\s\+\|^\[^\ze[^\]]\+\]:'

function! Preserve(command)
    " save last search, and cursor position
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business
    execute a:command
    " restore previous search history and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

augroup markdown
    autocmd!
    autocmd InsertLeave * :call Preserve("normal gqq<CR>")

    autocmd VimEnter * Goyo
    autocmd User GoyoEnter :call s:goyo_enter()
    autocmd User GoyoLeave :call s:goyo_leave()
augroup END

let g:goyo_width=100
let g:goyo_height="90%"
let g:goyo_linenr = 1

" https://github.com/junegunn/goyo.vim/issues/16#issuecomment-40553281
function! s:goyo_enter()
endfunction

function! s:goyo_leave()
    " Quit Vim if this is the only remaining buffer
    if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
        qa
    endif
endfunction

" Goyo doesn't preserve cursor position if closed with :q, because of some funky
" vim stuff under the hood (see referenced links). So, instead we alias the most
" common way I exit files :wq to :w|tabclose to still be able to retain the
" cursor position.
"
" https://github.com/junegunn/goyo.vim/issues/27#issuecomment-41520500
" https://github.com/junegunn/goyo.vim/issues/131#issuecomment-267383268
"
cnoreabbrev <expr> q getcmdtype() == ":" && getcmdline() == 'q' ? 'w\|tabclose' : 'q'
cnoreabbrev <expr> wq getcmdtype() == ":" && getcmdline() == 'wq' ? 'w\|tabclose' : 'wq'
