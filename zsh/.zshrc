## my zshrc based on grml and powerline

alias -g colorcopy="| sed 's/'\$(echo -e \"\\033\")'/'\$(echo -e \"\\033\\033\")'/g' | tee /dev/tty | xsel -bi"

# grml-zsh unset prompt
prompt off

POWERLINE_BINDINGS=/usr/share/powerline/bindings/

powerline-daemon -q  # run powerline daemon

source $POWERLINE_BINDINGS/zsh/powerline.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# key bindings fixes for urxvt
bindkey "^[[7~" beginning-of-line
bindkey "^[[8~" end-of-line
bindkey "^[[5~" beginning-of-history
bindkey "^[[6~" end-of-history
bindkey "^[[3~" delete-char
bindkey "^[[2~" quoted-insert

# key bindings fixes for alacritty/konsole
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

[ -f $HOME/.bashrc ] && source $HOME/.bashrc
[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local
export SHELL=/bin/zsh

# completion for Syu
compdef -e "words[1]=(pacman -Su);service=pacman;((CURRENT+=1));_pacman" Syu
compdef -e "words[1]=(cower -d);service=cower;((CURRENT+=1));_cower" Ga
compdef -e "words[1]=(cower -s);service=cower;((CURRENT+=1));_cower" Ssa


# added by travis gem
[ -f /home/farseerfc/.travis/travis.sh ] && source /home/farseerfc/.travis/travis.sh

# change systemd-boot default entry to reboot to windows
alias reboot-windows="sudo efivar -w -n 4a67b082-0a4c-41cf-b6c7-440b29bb8c4f-LoaderEntryDefault -f =(echo -n 'windows\0' | iconv -f utf-8 -t utf-16le)"

# Automatically change the directory in bash after closing ranger
#
# This is a bash function for .bashrc to automatically change the directory to
# the last visited one after ranger quits.
# To undo the effect of this function, you can type "cd -" to return to the
# original directory.

function ranger-cd {
    tempfile="$(mktemp)"
    /usr/bin/ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
}

