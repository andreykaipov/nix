#!/bin/sh

set -eu


install_gifsicle() {
    v='1.92'
    url="http://www.lcdf.org/gifsicle/gifsicle-$v.tar.gz"

    if ! [ -x ~/local/bin/gifsicle ]; then
        echo "Downloading"
        get gifsicle.tz "$url"

        echo "Extracting"
        tar fx gifsicle.tz

        echo "Compiling"
        cd gifsicle-*
        ./configure --quiet --prefix "$HOME/local" --disable-gifview
        make
        make install
        cd -
    fi

    gifsicle --version
}

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

install_gnucoreutils() {
    v='8.32'
    url="https://ftp.gnu.org/gnu/coreutils/coreutils-$v.tar.xz"

    if ! [ -d ~/local/libexec/coreutils ] || ! [ -x ~/local/bin/sha256sum ]; then
        echo "GNU Core Utilities package is missing"
        echo "Downloading"
        get coreutils.tz "$url"
        tar fx coreutils.tz

        echo "Compiling"
        cd coreutils-*
        ./configure --quiet --prefix "$HOME/local" --disable-dependency-tracking
        make
        make install
        cd -
    fi
}

install_homebrew() {
    v='master'
    url="https://github.com/Homebrew/brew/tarball/$v"

    if ! [ -x ~/local/opt/homebrew/bin/brew ]; then
        get homebrew.tz "$url"
        rm -rf ~/local/opt/homebrew
        mkdir -p ~/local/opt/homebrew
        tar fx homebrew.tz --strip-components 1 -C ~/local/opt/homebrew
    fi

    ln -sf ~/local/opt/homebrew/bin/brew -t ~/bin
    brew --version
}

install_nvim() {
    [ "$os" = linux ] && suffix=linux64 || [ "$os" = darwin ] && suffix=macos

    v='0.4.3'
    url="https://github.com/neovim/neovim/releases/download/v$v/nvim-$suffix.tar.gz"

    if ! [ -x ~/local/opt/nvim-*/bin/nvim ]; then
        echo "Neovim is missing"
        echo "Downloading Neovim"
        get nvim.tz "$url"
        echo "Extracting tarball to ~/local/opt"
        tar fx nvim.tz -C ~/local/opt
    fi

    ln -sf ~/local/opt/nvim-*/bin/nvim -t ~/bin
    nvim --version

    echo "Installing VIM plugins"
    nvim +PlugInstall +qa
}

install_dircolorshex() {
    url='https://raw.githubusercontent.com/andreykaipov/dircolors.hex/master/bin/dircolors.hex'

    if ! [ -x ~/dircolors.hex ]; then
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

    if ! [ -x ~/bin/win32yank.exe ]; then
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
    url="https://github.com/koalaman/shellcheck/releases/download/v$v/shellcheck-v$v.$os.x86_64.tar.xz"

    if ! [ -x ~/bin/shellcheck ]; then
        echo "shellcheck is either missing or has a mismatched version"
        echo "Downloading shellcheck"
        get shellcheck.tz "$url"
        tar fx shellcheck.tz --strip-components 1 -C ~/bin '*/shellcheck'
    fi

    shellcheck --version
}

install_go() {
    v='1.15.2'
    url="https://dl.google.com/go/go$v.$os-amd64.tar.gz"
    checksum="$(get - "$url.sha256")"

    if command -v go >/dev/null && [ -z "${REINSTALL_GO:=}" ]; then
        echo "nothing to do"
        return
    fi

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
    if [ -r "$HOME/local/opt/$lastfile" ] && [ -z "${REINSTALL_GO}" ]; then
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
    [ "$os" = linux ] && os=linux || [ "$os" = darwin ] && suffix=mac

    v='19.03.8'
    url="https://download.docker.com/$suffix/static/stable/x86_64/docker-$v.tgz"

    if ! [ -x ~/bin/docker ]; then
        echo "Downloading Docker tarball"
        get docker.tz "$url"
        tar fx docker.tz --strip-components 1 -C ~/bin '*/docker'
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
        ./configure --quiet --prefix ~/local \
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
        ./configure --quiet --prefix ~/local \
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
        ./configure --quiet --prefix ~/local --disable-echo
        make
        make install
        cd -
    fi

    yacc -V
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
        ./configure --quiet --prefix ~/local --enable-silent-rules
        make
        make install
        cd -
    fi

    LD_LIBRARY_PATH="$HOME/local/lib" tmux -V
}

install_bash5() {
    v='5.0'
    url="http://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz"

    if ! [ -x ~/local/bin/bash ]; then
        echo "bash is missing"
        echo "Downloading"
        get bash.tz "$url"

        echo "Extracting"
        rm -rf bash-*
        tar fx bash.tz

        echo "Compiling"
        cd bash-*
        ./configure --quiet --prefix ~/local
        make
        make install
        cd -
    fi

    bash --version
}

install_pyenv() {
    if ! [ -x ~/local/opt/pyenv/bin/pyenv ] || [ -n "${REINSTALL_PYENV:=}" ]; then
        rm -rf ~/local/opt/pyenv
        get - https://pyenv.run | PYENV_ROOT=~/local/opt/pyenv sh
    fi

    ln -sf ~/local/opt/pyenv/bin/pyenv -t ~/bin
    pyenv --version
}

install_jq() {
    [ "$os" = linux ] && suffix=linux64 || [ "$os" = darwin ] && suffix=osx-amd64

    v='1.6'
    url="https://github.com/stedolan/jq/releases/download/jq-$v/jq-$suffix"

    if ! [ -x ~/bin/jq ]; then
        echo "Downloading jq"
        get jq "$url"
        chmod +x jq
        mv jq ~/bin
    fi

    jq --version
}

install_yq() {
    [ "$os" = linux ] && suffix=linux_amd64 || [ "$os" = darwin ] && suffix=darwin_amd64

    v='3.3.2'
    url="https://github.com/mikefarah/yq/releases/download/$v/yq_$suffix"

    if ! [ -x ~/bin/yq ]; then
        echo "Downloading yq"
        get yq "$url"
        chmod +x yq
        mv yq ~/bin
    fi

    yq --version
}

install_upx() {
    v='3.96'
    url="https://github.com/upx/upx/releases/download/v$v/upx-$v-amd64_linux.tar.xz"

    if [ -n "${WSL_DISTRO_NAME:-}" ]; then
        echo "UPX doesn't work within WSL, so no point in installing it"
        echo "See https://github.com/upx/upx/issues/201 and https://github.com/microsoft/WSL/issues/3846"
        return
    fi

    if [ "$os" = darwin ]; then
        echo "Skipping UPX."
        echo "TODO: Install from source as binaries are not provided."
        return
    fi

    if ! [ -x ~/bin/upx ]; then
        echo "Downloading UPX"
        get upx.tz "$url"
        tar fx upx.tz --strip-components 1 -C ~/bin --wildcards '*/upx'
    fi

    upx --version
}

install_tre() {
    [ "$os" = linux ] && suffix=unknown-linux-gnu || [ "$os" = darwin ] && suffix=apple-darwin

    v='0.3.0'
    url="https://github.com/dduan/tre/releases/download/$v/tre-v$v-x86_64-$suffix.tar.gz"

    if ! [ -x ~/bin/tre ]; then
        echo "Downloading tre"
        get tre.tz "$url"
        echo "Extracting it"
        tar fx tre.tz -C ~/bin
    fi

    ~/bin/tre --version
}

install_cmake() {
    if ! [ -x ~/local/bin/cmake ] && ! ls -d ~/local/share/cmake-*; then
        get cmake.tz https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3-Darwin-x86_64.tar.gz
        mv ../cmake-*/CMake.app/Contents/share/* ~/local/share
        mv ../cmake-*/CMake.app/Contents/bin/* ~/local/bin
    fi

    cmake --version
}

install_barrier() {
    v='2.3.3'
    url="https://github.com/debauchee/barrier/releases/download/v$v/Barrier-$v-release.dmg"

    if ! [ -d /Applications/Barrier.app/ ]; then
        get barrier.dmg "$url"
        hdiutil attach barrier.dmg
        cp -r /Volumes/Barrier/Barrier.app/ /Applications/
        hdiutil detach /Volumes/Barrier/
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

    echo "Creating ~/local/opt and ~/bin directories"
    mkdir -p ~/local/opt
    mkdir -p ~/bin
    echo

    case "$(uname -s)" in
    Linux)  os=linux ;;
    Darwin) os=darwin ;;
    *)      >&2 echo "Unknown OS"; exit 1;;
    esac

    if [ "$os" = darwin ]; then
        echo "Updating macOS domain defaults with our property lists"

        for plist in ~/.config/macos/*.plist; do
            domain="$(basename "${plist%.*}")"
            echo "$domain"
            defaults import "$domain" "$plist"
        done
    fi

    # All of the above install scripts install binaries into either ~/bin or
    # ~/local/bin. We set this PATH here so we can test each binary at the end
    # of its installation script. As this file is not meant to be sourced, this
    # is not permanent.
    export PATH="$HOME/bin:$HOME/local/bin:$PATH"

    pkgs='
        # Built from source using autoconf and make, all prefaced to ~/local.
        # Follows the FHS: ~/local/{bin,etc,include,lib,opt,share}
        gnucoreutils
        libevent
        ncurses
        yacc
        tmux
        bash5
        bash_completions
        gifsicle
        # cmake

        # These are like package-thingies with binaries relying on the source
        # code libraries in the package. Installed to ~/local/opt. Binaries are
        # symlinked from ~/local/opt/*/bin/* to ~/bin.
        go
        nvim
        pyenv
        # homebrew

        # Statically linked binaries intalled to ~/bin directly.
        dircolorshex
        dockercli
        jq
        yq
        shellcheck
        tre
        upx
        win32yank

        # Applications
        barrier
    '

    nlx="$(printf '\nx')"; nl="${nlx%x}"; IFS="$nl"
    for o in $pkgs; do
        # trim spaces, and skip comments or empty lines
        o="${o#${o%%[![:space:]]*}}"
        case "$o" in ''|\#*) continue; esac

        echo "Installing $o"
        eval "install_$o"
        echo
    done

    if [ -n "${WSL_DISTRO_NAME:-}" ]; then
        echo "Running within WSL distro"

        echo "Installing Windows Terminal settings"
        cp ~/.config/windows.terminal/settings.json /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/
    fi

    cd -

    #echo "Templating Alacritty config"
    #<~/.config/alacritty/alacritty.tmpl.yml envsubst "\$HOME" > ~/.config/alacritty/alacritty.yml

    echo "Done"
}

#
# if xcode-select -p >/dev/null; then
#     echo "XCode CLI tools already installed"
#     return
# fi
#
# touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
# if ! softwareupdate --list --no-scan | grep -q 'Command Line Tools'; then
#     echo "Can't find the update for the XCode CLI tools. Scanning..."
#     softwareupdate --list
# fi
# if ! softwareupdate --list --no-scan | grep -q 'Command Line Tools'; then
#     1>&2 echo "Can't find the update for the XCode CLI tools at all... :/"
#     exit 3
# fi
# xcodeclitools="$(softwareupdate --list --no-scan | grep -Eo 'Command Line Tools for Xcode-.+')"
# softwareupdate --install "$xcodeclitools"
#
# https://github.com/Homebrew/brew/blob/master/docs/Installation.md#untar-anywhere
# mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew

main
