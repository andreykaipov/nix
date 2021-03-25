" More natural completion
" https://vim.fandom.com/wiki/Make_Vim_completion_popup_menu_work_just_like_in_an_IDE
" https://vim.fandom.com/wiki/Improve_completion_popup_menu

set completeopt=menuone,longest,preview

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
" ctrl+space to open omni completion menu, closing previous if open and opening
" new menu without changing the text, with the pseudo-selection trick above
inoremap <expr> <C-Space>
    \ (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') .
    \ '<C-x><C-o><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'
" alt+space same thing as above
inoremap <expr> <M-Space>
    \ (pumvisible() ? (col('.') > 1 ? '<Esc>i<Right>' : '<Esc>i') : '') .
    \ '<C-x><C-o><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>'

" shift+tab to start ins-menu-completion, same tricks as above.
" however, instead of closing any current menu open, shift+tab navigates up.
inoremap <expr> <S-Tab>
    \ (pumvisible() ? "\<C-p>" :
    \ '<C-x><C-p><C-r>=pumvisible() ? "\<lt>C-n>\<lt>C-p>\<lt>Down>" : ""<CR>')
