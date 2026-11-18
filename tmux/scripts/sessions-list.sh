#!/bin/sh
# usage: sessions-list.sh <current-session-name>
cur="$1"
i=0
tmux list-sessions -F '#{session_created} #{session_name}' | sort -n | cut -d' ' -f2- |
while IFS= read -r s; do
  i=$((i+1))
  if [ "$s" = "$cur" ]; then
    printf '#[bg=#f6c177,fg=#191724,bold] %s: %s #[default] ' "$i" "$s"
  else
    printf '#[fg=#908caa] %s: %s #[default] ' "$i" "$s"
  fi
done
