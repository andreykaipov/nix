## intro

Hey - this is my home directory.

WHAT? You've made your home directory a Git repository? Are you crazy?

Crazy is subjective, but yes.

## setup

Are you on a new machine? Run the following.

```console
$ curl -sLo- https://raw.githubusercontent.com/andreykaipov/home/master/meta/init.sh | sh -
$ ./meta/install.sh
```

## work

Work environment variables go in `~/.shenv.work`.

Work email for Git goes in `~/.config/git/work`. This only applies to projects
under `~/projects/work`. See `~/.config/git` for a complete understanding.

## neovim configuration

At a glance, the neovim directory structure looks like:

```console
.config/
└── nvim
    ├── init.vim                  (inits vim-plug and sets non-plugin options)
    ├── plugs.vim                 (just lines of `Plugin 'some/plugin'`)
    ├── ftdetect/*.vim            (detects and set the filetype for files not handled by plugins)
    ├── after/plugin/init.vim     (sets options after plugin initialization)
    └── after/ftplugin/<ft>.vim   (sets options specific to <ft> files after plugin initialization)
```

This configuration tries to use Vim's startup order to its advantage
to moduralize every bit of configuration and keep everything neat.

| file                      | contains                                                                  |
|--------------------------:|---------------------------------------------------------------------------|
| `init.vim`                | vim-plug installation, and non-plugin-specific configuration options      |
| `plugs.vim`               | plugins we'd like to install; just lines of `Plug 'some/plugin'`          |
| `ftdetect/*.vim`          | autocmds to detect and set the filetypes for files not handled by plugins |
| `after/plugin/init.vim`   | plugin-specific configuration options                                     |
| `after/ftplugin/<ft>.vim` | options specific to <ft> files, ran after plugin initilization            |

### helpful articles

https://vimways.org/2018/debugging-your-vim-config (keeping your vimscript neat)
https://learnvimscriptthehardway.stevelosh.com/chapters/42.html (quick overview of a plugin directory structure)
