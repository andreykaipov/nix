#!/bin/sh

cd ~/.meta/windows || exit

{
    cat admin-prehook.ps1
    for s in configure-*.ps1; do
        echo "echo Running $s"
        wslpath -w "$s"
    done
    echo pause
} > /tmp/lol.ps1

powershell.exe -File /tmp/lol.ps1
