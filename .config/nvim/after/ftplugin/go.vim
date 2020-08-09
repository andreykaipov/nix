" let b:ale_fixers = ['gofmt', 'goimports']

let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 1
let g:go_metalinter_command = 'golangci-lint run'

let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_array_whitespace_error = 1
let g:go_highlight_chan_whitespace_error = 1
let g:go_highlight_space_tab_error = 1
let g:go_highlight_trailing_whitespace_error = 1
let g:go_textobj_enabled = 1
let g:go_auto_type_info = 1

nmap <leader>b <Plug>(go-build)
nmap <leader>r <Plug>(go-run)
nmap <leader>gl :GoMetaLinter<cr>
