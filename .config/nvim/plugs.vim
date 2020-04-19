Plug 'https://github.com/tpope/vim-sleuth'

Plug 'https://github.com/dense-analysis/ale'
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}
