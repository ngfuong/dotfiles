#!/bin/sh
# usage: session-goto.sh <n>
target=$(tmux list-sessions -F '#{session_created} #{session_name}' | sort -n | cut -d' ' -f2- | sed -n "${1}p")
[ -n "$target" ] && tmux switch-client -t "=$target"
