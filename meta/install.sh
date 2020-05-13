#!/bin/sh
# shellcheck disable=SC2012,SC2016

metafiles="$(awk '/metaf/,/endmetaf/' .gitignore | awk '/!/' | cut -c2- | tr '\n' '|' | sed 's/.$//')"
configs="$(git ls-files | cut -d/ -f1 | sort | uniq | grep -vEx "$metafiles")"

echo "Removing existing symlinks in \$HOME pointing to this directory"
ls -al ~ | awk -v "pwd=$PWD" '/^l/ && $11~pwd {print $9}' | xargs -I% sh -c 'echo rm -f "$HOME/%"; rm -f "$HOME/%"'

for c in $configs; do
        d="$HOME/$c"
        if [ -e "$d" ] && ! [ -L "$d" ]; then
                >&2 echo "File \$HOME/$c already exists and isn't a symlink. Backing up to \$HOME/$c.bak."
                mv "$d" "$d.bak"
        fi

        ln -s "$PWD/$c" -t "$HOME"
done

echo "Created symlinks in \$HOME for top-level files:"
echo "$configs" | \
        xargs -I% ls -l ~/% | \
        awk '{printf "- %-30s -> %s\n",$(NF-2),$NF}' | \
        sort

echo "Installing VIM plugins"
nvim +PlugInstall +qa

echo "Templating Alacritty config"
<.config/alacritty/alacritty.tmpl.yml envsubst '$HOME' > .config/alacritty/alacritty.yml

echo "Done"
