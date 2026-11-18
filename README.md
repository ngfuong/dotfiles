
# dotfiles

Make a backup of your dotfiles in case things go nuts

**Credits:** Big thanks to @ericjaychi for his original [repo](https://github.com/ericjaychi/sample-dotfiles) and [instructions](https://betterprogramming.pub/managing-your-dotfiles-with-git-4dee603a19a2)

## How to use

### 1. Fork this repository and clone it to your local device

```
git clone git@github.com:ngfuong/dotfiles
```

### 2. Copy your dot files

For example, you can copy your `.zshrc` file from home directory (`~`) to your local repository (without the `.` prefix for management purposes)

```
cp ~/.zshrc ~/dotfiles/zshrc
```

You can overwrite or remove any dot files in the forked repository that is not needed for backup.

### 3. Symlink your files

Edit the **Variables** section in the `make-symlinks.sh` file

```
########## Variables

# dotfiles directory (the directory this script lives in)
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# backup directory for existing dotfiles that get replaced
olddir="$dir/dotfiles_old"

# list of files/folders to symlink into $HOME as ~/.<entry>
# paths are relative to this repo and must exist here
# OSX
files="zshrc tmux.conf tmux/scripts config/nvim"

##########
```

Each entry becomes `~/.<entry>` (e.g. `zshrc` → `~/.zshrc`). Adjust the `files` list to the files you want to manage.

Run the script (in some case you have to make the file executable before it can be run)

```
# make the file executable
chmod +x make-symlinks.sh
./make-symlinks.sh
```

The script is safe to re-run. Entries already linked correctly are skipped. Any existing file or symlink in the way is moved to `dotfiles_old/` first. If a backup with the same name already exists there, the script stops so nothing is overwritten.

### 4. Backup your files

Edit the dotfiles (e.g `.bashrc`) in your home directory normally and the files in your backup repository will be updated automatically.
If you want to record your changes, enter the local repository and stage the changes.

```
git add zshrc 
git commit -m "Updated dot zshrc"
```
