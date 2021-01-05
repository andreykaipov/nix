" theme and status line that i'll get tired of later
Plug 'liuchengxu/space-vim-theme'
Plug 'itchyny/lightline.vim'

" handy one-off commands I might want to run sometimes
" TODO - just get rid of vim-markdown and replace with my own (auto)cmds
" also read http://vimcasts.org/episodes/aligning-text-with-tabular-vim again
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'guns/xterm-color-table.vim'

" for general text editing
Plug 'tpope/vim-sleuth'
Plug 'dense-analysis/ale'
Plug 'lilydjwg/colorizer'

" language specific
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" fix yaml highlighting. sometimes it's weird especially for ansible roles
Plug 'stephpy/vim-yaml'
Plug 'pearofducks/ansible-vim'

" terraform
Plug 'hashivim/vim-terraform'
Plug 'juliosueiras/vim-terraform-completion'

" syntax linting
Plug 'vim-syntastic/syntastic'
" async linting and make framework
Plug 'neomake/neomake'
" async completion and make framework
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" nix
Plug 'LnL7/vim-nix'

" javascript
Plug 'pangloss/vim-javascript'
