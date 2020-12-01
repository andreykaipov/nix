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

_Secret_ work environment variables go in `~/.shenv.work`.

Set the Git emails accordingly in `~/.config/git/core`.

## neovim configuration

### helpful articles

https://vimways.org/2018/debugging-your-vim-config (keeping your vimscript neat)
https://learnvimscriptthehardway.stevelosh.com/chapters/42.html (quick overview of a plugin directory structure)
