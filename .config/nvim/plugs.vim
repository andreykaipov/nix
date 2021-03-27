" theme and status line that i'll get tired of later
Plug 'liuchengxu/space-vim-theme'
Plug 'itchyny/lightline.vim'

" handy one-off commands I might want to run sometimes
" TODO - just get rid of vim-markdown and replace with my own (auto)cmds
" also read http://vimcasts.org/episodes/aligning-text-with-tabular-vim again
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'guns/xterm-color-table.vim'

" detect buffer options and set them automatically per file
Plug 'tpope/vim-sleuth'

" colorize text in hex
" TODO: maybe get rid of lilydjwg's colorizer?
" I'll see if it gives me issues
" Plug 'lilydjwg/colorizer'
"
" chrisbra's colorizes text in ansi-escaped colors too
"
Plug 'chrisbra/Colorizer'

" async linting
Plug 'dense-analysis/ale'

" async completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" yaml
" fixes yaml highlighting. sometimes it's weird especially for ansible roles
Plug 'stephpy/vim-yaml'
Plug 'pearofducks/ansible-vim'

" terraform
Plug 'hashivim/vim-terraform'
Plug 'juliosueiras/vim-terraform-completion'

" nix
Plug 'LnL7/vim-nix'

" javascript
Plug 'pangloss/vim-javascript'

" powershell
Plug 'zigford/vim-powershell'

" dope
" Plug 'timburgess/extempore.vim'
