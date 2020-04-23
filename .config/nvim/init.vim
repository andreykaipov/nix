if has('neovim')
    let root = stdpath('config')
else
    let root = expand('~/.config/nvim')
endif

" install Vim Plug for Neovim
" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
"
let vimplug_local  = printf('%s/autoload/plug.vim', root)
let vimplug_remote = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

if !filereadable(vimplug_local)
    if !executable('curl')
        echoerr "You're missing curl..."
        sleep 1000m
        execute 'q!'
    endif

    echo 'Installing Vim-Plug...'
    silent exec printf('!curl -sLo %s %s --create-dirs', vimplug_local, vimplug_remote)
    augroup vim_plug
        autocmd!
        autocmd VimEnter * PlugInstall --sync
    augroup END
endif

" install plugins
"
call plug#begin(printf('%s/autoload/plugs', root))
    exec printf('source %s/plugs.vim', root)
call plug#end()

" preserve history after closing
"
if has('persistent_undo')
    set undofile
    exec printf('set undodir=%s/undo', root)
endif

" sets the system register (+) as the default one for copying and pasting junk
"
set clipboard=unnamedplus
