## (neo)vim configuration

At a glance, the (neo)vim directory structure looks like:

```console
.config/
└── nvim
    ├── init.vim                  (inits vim-plug and sets non-plugin options)
    ├── plugs.vim                 (just lines of `Plugin 'some/plugin'`)
    ├── ftdetect/*.vim            (detects and set the filetype of files not handled by plugins)
    ├── ftplugin/<ft>.vim         (sets buffer-local options for .<ft> files)
    ├── after/plugin/*.vim        (sets options after plugin initlization; contains guards)
    ├── after/ftdetect/*.vim      (same as above but sourced after plugins are loaded)
    └── after/ftplugin/<ft>.vim   (same as above but sourced after plugins are loaded)
```

This configuration tries to use Vim's startup order to its advantage
to moduralize every bit of configuration and keep everything neat.

| file                      | contains                                                                                                                                                |
|--------------------------:|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| `init.vim`                | vim-plug installation, and non-plugin-specific configuration options                                                                                    |
| `plugs.vim`               | plugins we'd like to install                                                                                                                            |
| `ftdetect/*.vim`          | autocmds to detect and set the filetype of files, if not handled by a plugin                                                                            |
| `ftplugin/<ft>.vim`       | buffer-local options for the `<ft>` filetype, before plugins are sourced, e.g. we want to use the light theme of our colorscheme, but only for Go files |
| `after/ftplugin/<ft>.vim` | exactly like the above, but after plugins are sourced, e.g. setting ALE fixers appropriately per file                                                   |
| `after/plugin/*.vim`      | plugin-specific configuration options, under files aptly named for the options they set, e.g. setting global ALE options under `ale.vim`                |
| `after/plugin/misc.vim`   | plugin-specific configuration options, that wouldn't make sense to moduralize into their own file, e.g. setting a colorscheme installed via a plugin      |


### helpful articles

https://vimways.org/2018/debugging-your-vim-config (keeping your vimscript neat)
https://learnvimscriptthehardway.stevelosh.com/chapters/42.html (quick overview of a plugin directory structure)
