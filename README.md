## intro

Hey - this is my home directory.

WHAT? You've made your home directory a Git repository? Are you crazy?

Crazy is subjective, but yes.

## setup

Are you on a new machine? Run the following from your home directory.

```console
$ curl -sLo- https://raw.githubusercontent.com/andreykaipov/home/master/.meta/init.sh | sh -
$ ./.meta/install.sh
```

## work

_Secret_ work environment variables go in `~/.shenv.work`.

Set the Git email accordingly in `~/.config/git/work`.
