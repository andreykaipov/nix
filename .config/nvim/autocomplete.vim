" More natural completion
" https://vim.fandom.com/wiki/Make_Vim_completion_popup_menu_work_just_like_in_an_IDE
" https://vim.fandom.com/wiki/Improve_completion_popup_menu

"set completeopt=menuone,noselect,preview ",longest,preview
set completeopt=menuone,longest,noinsert,preview
"set splitbelow

" use tab and shift+tab to scroll through the popup window
" S-Tab is overriden further below, but left here for completeness
inoremap <expr> <Tab>  pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" or ctrl+j or ctrl+k
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<Down>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<Up>"

" or ctrl+d or ctrl+u to navigate the list quicker
inoremap <expr> <C-d> pumvisible() ? "\<C-n>\<C-n>\<C-n>" : "\<C-d>"
inoremap <expr> <C-u> pumvisible() ? "\<C-p>\<C-p>\<C-p>" : "\<C-u>"

" no new line on enter of completion
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" leave cursor at end of text when pressing escape
inoremap <expr> <Esc> pumvisible() ? "\<C-e>" : "\<Esc>"

" keeps completion entries highlighted whenever we keep typing after
" a completion, allowing for the menu to narrow our entries while we type!
inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
inoremap <expr> <C-p> pumvisible() ? '<C-p>' :
  \ '<C-p><C-r>=pumvisible() ? "\<lt>Up>" : ""<CR>'

" hide preview window after completions
" only relevant for preview windows in normal buffers
augroup closepumpreview
    autocmd!
    autocmd CursorMovedI,InsertLeave *
    \ if &buftype == '' && pumvisible() == 0 | pclose | endif
augroup END

" new shortcuts:
"
" shift+tab for omni completion, shift+tab again for user completion
inoremap <expr> <S-Tab>
    \ pumvisible() ?
    \ '<C-x><C-n><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>' :
    \ '<C-x><C-o><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'

inoremap <expr> <C-Space>
    \ pumvisible() ?
    \ '<C-x><C-n><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>' :
    \ '<C-x><C-o><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'
