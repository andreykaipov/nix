#!/bin/sh

todo="$(git clean -xdffn)"

if [ -z "$todo" ]; then
        echo "Configuration is already pristine!"
else
        echo "$todo"
        echo
        echo "press <enter> to continue, <ctrl>+c (^C) to cancel"
        read -r
        git clean -xdff
fi
