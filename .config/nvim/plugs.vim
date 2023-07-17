Plug 'liuchengxu/space-vim-theme'     " spaaaaaace
Plug 'vimpostor/vim-tpipeline'        " vim status line into tmux pane title
Plug 'christoomey/vim-tmux-navigator' " navigate between vim and tmux panes easier
Plug 'TaDaa/vimade'                   " dim inactive vim windows
Plug 'tpope/vim-vinegar'              " better file browser?
Plug 'github/copilot.vim'             " i, for one, welcome our new insect overlords

Plug 'chaoren/vim-wordmotion' " bettter word motions
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

" LSP
Plug 'neovim/nvim-lspconfig'

" async linting
Plug 'dense-analysis/ale'

" async completion
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

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
"

" markdown writing
Plug 'junegunn/goyo.vim'
Plug 'preservim/vim-pencil'
" one sentence per line for text/markdown files
Plug 'whonore/vim-sentencer'

"
Plug 'embear/vim-localvimrc'

Plug 'AndrewRadev/splitjoin.vim'
