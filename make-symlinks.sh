#!/bin/bash
############################
# make-symlinks.sh
# Creates symlinks from $HOME to the dotfiles in this repository.
# Existing files are backed up to dotfiles_old/ first.
# Safe to re-run: entries that are already linked correctly are skipped.
############################

set -euo pipefail

########## Variables

# dotfiles directory (the directory this script lives in)
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# backup directory for existing dotfiles that get replaced
olddir="$dir/dotfiles_old"

# list of files/folders to symlink into $HOME as ~/.<entry>
# paths are relative to this repo and must exist here
# LINUX
# files="bashrc zshrc tmux.conf config/nvim/init.vim config/i3/config"
# OSX
files="zshrc tmux.conf tmux/scripts config/nvim"

##########

mkdir -p "$olddir"

for file in $files; do
  src="$dir/$file"
  dst="$HOME/.$file"

  if [ ! -e "$src" ]; then
    echo "SKIP: $src does not exist in the repo"
    continue
  fi

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "OK: $dst already links to $src"
    continue
  fi

  # back up anything in the way (a real file/dir or a symlink to somewhere else)
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup="$olddir/${file//\//_}"
    if [ -e "$backup" ] || [ -L "$backup" ]; then
      echo "ERROR: backup target $backup already exists; move it aside and re-run" >&2
      exit 1
    fi
    echo "Backing up $dst -> $backup"
    mv "$dst" "$backup"
  fi

  mkdir -p "$(dirname "$dst")"
  echo "Linking $dst -> $src"
  ln -s "$src" "$dst"
done
