#!/bin/sh

metafiles="$(awk '/metaf/,/endmetaf/' .gitignore | awk '/!/' | cut -c2- | paste -sd\|)"
configs="$(find . -depth 1 | cut -c3- | grep -vEx ".git|$metafiles")"

for c in $configs; do
        d="$HOME/$c"
        if [ -e "$d" ] && ! [ -L "$d" ]; then
                >&2 echo "File \$HOME/$c already exists and isn't a symlink. Backing up to \$HOME/$c.bak."
                mv "$d" "$d.bak"
        fi

        ln -fs "$PWD/$c" -t "$HOME"
done

echo "Created symlinks in \$HOME for:"
echo "$configs" | xargs -n1 echo -

echo "Installing VIM plugins"
nvim +PlugInstall +qa
