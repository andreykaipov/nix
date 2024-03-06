#!/bin/sh
#
# Similar to my old ~/.shlogin style of login, except it uses Zellij instead of tmux.
#
# The following script is intended to be sourced by a bare bones shell that will
# pop us into a Zellij session. Home Manager can do this for us via
# programs.zellij.enableZshIntegration, which adds the following to our zshrc:
# `eval $(zellij setup --generate-auto-start zsh)`, which configures zsh to auto-attach
# in a similar way, but it's honestly not the cleanest having it alongside all of our other
# zshrc configuration code.
#
# It's supposed to be invoked by a very minimal shell.

ensure_zellij() {
	if [ -n "$ZELLIJ" ]; then
		echo "We're already inside of a Zellij session"
		exit
	fi

	if zellij list-sessions -ns | grep -qx local; then
		echo "Zellij session 'local' already exists"
		echo "If you'd really like to, we'll attach into it in 3 seconds"
		echo "Otherwise, send ^C"
		sleep 3
		exec zellij attach local
	else
		echo "Creating new Zellij session 'local'"
		exec zellij --session local
	fi
}

main() {
	if [ -z "$BOOTSTRAP" ]; then
		echo "BOOTSTRAP is not set. Set if you really want to run this."
		sleep 5
		exit 1
	fi

	# on macos, sets system paths
	if [ -x /usr/libexec/path_helper ]; then
		eval $(/usr/libexec/path_helper -s)
	fi

	# shellcheck source=/dev/null
	# . ~/.nix-profile/etc/profile.d/nix.sh
	. ~/.nix-profile/bin/_bootstrap.source.sh
	# . ~/bin/_source-nix.sh

	cd ~ || exit
	ensure_zellij
	# exec bash
}

main "$@"
