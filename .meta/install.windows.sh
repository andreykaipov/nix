#!/bin/sh

cd ~/.meta/windows || exit

cat admin-prehook.ps1 configure-sshd.ps1 >/tmp/1.ps1

powershell.exe -File /tmp/1.ps1
