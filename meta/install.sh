#!/bin/sh

set -eu

install_bash_completions() {
    v='2.10'
    url="https://github.com/scop/bash-completion/releases/download/$v/bash-completion-$v.tar.xz"

    if ! [ -r ~/local/share/bash-completion/bash_completion ]; then
        echo "Bash completion package is missing"
        echo "Downloading"
        get bash-completion.tz "$url"

        echo "Extracting"
        rm -rf bash-completion; mkdir bash-completion
        tar fx bash-completion.tz --strip-components 1 -C bash-completion

        echo "Compiling"
        cd bash-completion
        ./configure --prefix "$HOME/local"
        make
        make install
        cd -
    fi

    completions_dir="$HOME/local/share/bash-completion/completions"

    if ! [ -r "$completions_dir/git" ]; then
        git_v="$(git --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"
        git_url="https://raw.githubusercontent.com/git/git/v$git_v/contrib/completion/git-completion.bash"
        get "$completions_dir/git" "$git_url"
    fi
}


install_nvim() {
    v='0.4.3'
    url="https://github.com/neovim/neovim/releases/download/v$v/nvim-linux64.tar.gz"

    if ! [ -x ~/local/opt/nvim-linux64/bin/nvim ]; then
        echo "Neovim is missing"
        echo "Downloading Neovim"
        get nvim.tz "$url"
        echo "Extracting tarball to ~/local/opt"
        tar fx nvim.tz -C ~/local/opt
    fi

    ln -sf ~/local/opt/nvim-linux64/bin/nvim -t ~/bin
    nvim --version

    echo "Installing VIM plugins"
    nvim +PlugInstall +qa
}

install_dircolorshex() {
    url='https://raw.githubusercontent.com/andreykaipov/dircolors.hex/master/bin/dircolors.hex'

    if ! command -v ~/dircolors.hex; then
        get dircolors.hex "$url"
        chmod +x dircolors.hex
        mv dircolors.hex ~/bin
    fi

    command -v dircolors.hex
}

install_win32yank() {
    v='0.0.4'
    url="https://github.com/equalsraf/win32yank/releases/download/v$v/win32yank-x64.zip"

    if [ -z "${WSL_DISTRO_NAME:-}" ]; then
        echo "Not running within WSL distro; skipping"
        return
    fi

    if ! command -v ~/bin/win32yank.exe >/dev/null; then
        echo "win32yank.exe is missing"
        echo "Downloading it"
        get win32yank.zip "$url"
        echo "Extracting it"
        unzip -p win32yank.zip win32yank.exe > ~/bin/win32yank.exe
        chmod +x ~/bin/win32yank.exe
    fi

    command -v win32yank.exe
}


install_shellcheck() {
    v='0.7.1'
    url="https://github.com/koalaman/shellcheck/releases/download/v$v/shellcheck-v$v.linux.x86_64.tar.xz"

    if ! command -v ~/bin/shellcheck >/dev/null; then
        echo "shellcheck is either missing or has a mismatched version"
        echo "Downloading shellcheck"
        get shellcheck.tz "$url"
        tar fx shellcheck.tz --strip-components 1 -C ~/bin --wildcards '*/shellcheck'
    fi

    shellcheck --version
}

install_go() {
    v='1.14.2'
    url="https://dl.google.com/go/go$v.linux-amd64.tar.gz"
    checksum="$(curl -sL "$url.sha256")"

    if ! [ -r go.tz ]; then
        echo "Downloading Go tarball..."
        get go.tz "$url"
    fi

    if echo "$checksum go.tz" | sha256sum --check --status; then
        echo "Go tarball checksums match"
    else
        echo "Go tarball checksums do not match"
        echo "Verify installation script"
        exit 2
    fi

    lastfile="$(tar ft go.tz | tail -n1)"
    if [ -r "$HOME/local/opt/$lastfile" ]; then
        echo "Looks like we've already extracted the tarball"
        echo "You might want to verify the Go installation"
    else
        echo "Extracting tarball to ~/local/opt"
        tar fx go.tz -C ~/local/opt --totals
    fi

    echo "Creating symlinks from ~/local/opt/go/bin to ~/bin"
    for b in ~/local/opt/go/bin/*; do
        ln -sf "$b" -t ~/bin
    done

    go version
}

install_dockercli() {
    v='19.03.8'
    url="https://download.docker.com/linux/static/stable/x86_64/docker-$v.tgz"

    if ! command -v ~/bin/docker >/dev/null; then
        echo "Downloading Docker tarball"
        get docker.tz "$url"
        tar fx docker.tz --strip-components 1 -C ~/bin --wildcards '*/docker'
    fi

    docker version -f '{{.Client}}' || true
    printf "\e[1;35mNOTE: Only the CLI has been installed. For functionality, please set DOCKER_HOST in your environment.\e[0m\n"
}

install_libevent() {
    v='2.1.11'
    url="https://github.com/libevent/libevent/releases/download/release-$v-stable/libevent-$v-stable.tar.gz"

    if ! { [ -r ~/local/lib/libevent.a ] && [ -d ~/local/include/event2 ]; }; then
        echo "libevent package is missing"
        echo "Downloading"
        get libevent.tz "$url"

        echo "Extracting"
        rm -rf libevent-*
        tar fx libevent.tz

        echo "Compiling"
        cd libevent-*
        ./configure --prefix ~/local \
            --disable-debug-mode \
            --disable-samples \
            --disable-libevent-regress \
            --enable-silent-rules
            #--enable-shared
        make
        make install
        cd -
    fi
}

install_ncurses() {
    # no version we bleeding
    url="https://invisible-island.net/datafiles/release/ncurses.tar.gz"

    if ! { [ -r ~/local/lib/libncurses_g.a ] && [ -d ~/local/include/ncurses ]; }; then
        echo "ncurses package is missing"
        echo "Downloading"
        get ncurses.tz "$url"

        echo "Extracting"
        rm -rf ncurses-*
        tar fx ncurses.tz

        echo "Compiling"
        cd ncurses-*
        ./configure --prefix ~/local \
            --without-ada \
            --without-cxx \
            --without-cxx-binding \
            --without-manpages \
            --without-normal \
            --without-tests \
            --without-develop \
            --disable-echo
            #--with-termlib
            #--enable-pc-files
            #--with-pkg-config-libdir "$HOME/local/lib/pkgconfig"
        make
        make install
        cd -
    fi
}

install_yacc() {
    # no version we bleeding
    url="https://invisible-island.net/datafiles/release/byacc.tar.gz"

    if ! [ -x ~/local/bin/yacc ]; then
        echo "yacc is missing"
        echo "Downloading"
        get byacc.tz "$url"

        echo "Extracting"
        rm -rf byacc-*
        tar fx byacc.tz

        echo "Compiling"
        cd byacc-*
        ./configure --prefix ~/local --disable-echo
        make
        make install
        cd -
    fi
}

# variation of https://github.com/tmux/tmux/wiki/Installing
install_tmux() {
    v='3.1b'
    url="https://github.com/tmux/tmux/releases/download/$v/tmux-$v.tar.gz"

    if ! [ -x ~/local/bin/tmux ]; then
        echo "tmux is missing"
        echo "Downloading"
        get tmux.tz "$url"

        echo "Extracting"
        rm -rf tmux-*
        tar fx tmux.tz

        echo "Compiling"
        cd tmux-*
        export LDFLAGS="-L${HOME}/local/lib"
        export CFLAGS="-I${HOME}/local/include -Wno-unused-result"
        ./configure --prefix ~/local --enable-silent-rules
        make
        make install
        cd -
    fi

    LD_LIBRARY_PATH="$HOME/local/lib" ~/local/bin/tmux -V
}

install_pyenv() {
    curl https://pyenv.run | sh
}

install_jq() {
    v='1.6'
    url="https://github.com/stedolan/jq/releases/download/jq-$v/jq-linux64"

    if ! command -v ~/bin/jq >/dev/null; then
        echo "Downloading jq"
        get jq "$url"
        chmod +x jq
        mv jq ~/bin
    fi

    jq --version
}

install_upx() {
    v='3.96'
    url="https://github.com/upx/upx/releases/download/v$v/upx-$v-amd64_linux.tar.xz"

    if ! command -v ~/bin/upx >/dev/null; then
        echo "Downloading UPX"
        get upx.tz "$url"
        tar fx upx.tz --strip-components 1 -C ~/bin --wildcards '*/upx'
    fi

    # upx --version
}

install_tre() {
    v='0.3.0'
    url="https://github.com/dduan/tre/releases/download/$v/tre-v$v-x86_64-unknown-linux-gnu.tar.gz"

    if ! [ -x ~/bin/tre ]; then
        echo "Downloading tre"
        get tre.tz "$url"
        echo "Extracting it"
        tar fx tre.tz -C ~/bin
    fi

    ~/bin/tre --version
}

get() {
    if command -v wget >/dev/null; then
        wget -qO "$@"
    elif command -v curl >/dev/null; then
        curl -sLo "$@"
    else
        echo "How does this system not have neither wget nor curl?"
        exit 1
    fi
}

main() {
    echo "Moving to /tmp"
    cd /tmp || exit

    echo "Creating ~/local/opt and ~/bin directories"
    mkdir -p ~/local/opt
    mkdir -p ~/bin
    echo

    pkgs='
        dircolorshex
        bash_completions

        win32yank
        jq
        shellcheck
        tre
        upx

        go
        nvim
        dockercli

        libevent
        ncurses
        yacc
        tmux
    '
    for o in $pkgs; do
        echo "Installing $o"
        eval "install_$o"
        echo
    done

    cd -
    echo "Templating Alacritty config"
    <~/.config/alacritty/alacritty.tmpl.yml envsubst "\$HOME" > ~/.config/alacritty/alacritty.yml

    echo "Done"
}

main
