#!/bin/sh

set -eu

install_nvim() {
    v='0.4.3'
    url="https://github.com/neovim/neovim/releases/download/v$v/nvim-linux64.tar.gz"

    if ! command -v ~/bin/nvim >/dev/null; then
        echo "Neovim is missing"
        echo "Downloading Neovim"
        get nvim.tz "$url"
        echo "Extracting tarball to ~/local"
        tar fx nvim.tz -C ~/local
    fi

    ln -sf ~/local/nvim-linux64/bin/nvim -t ~/bin
    nvim --version
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

    if [ -z "$WSL_DISTRO_NAME" ]; then
        echo "Not running within WSL distro; skipping"
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
    if [ -r "$HOME/local/$lastfile" ]; then
        echo "Looks like we've already extracted the tarball"
        echo "You might want to verify the Go installation"
    else
        echo "Extracting tarball to ~/local..."
        tar fx go.tz -C ~/local/ --totals
    fi

    echo "Creating symlinks from ~/local/go/bin to ~/bin"
    for b in ~/local/go/bin/*; do
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

install_yash() {
    v='2.49'
    url="https://github.com/magicant/yash/releases/download/$v/yash-$v.tar.xz"

    if ! command -v ~/bin/yash >/dev/null; then
        echo "Downloading yash"
        get yash.tz "$url"
        mkdir -p yash
        tar fx yash.tz -C yash
    fi
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

    echo "Creating ~/local and ~/bin directories"
    mkdir -p ~/local
    mkdir -p ~/bin

    echo
    for o in nvim dircolorshex win32yank shellcheck jq upx go dockercli; do
        echo "Installing $o"
        install_$o
        echo
    done

    echo "Done"
}

main
