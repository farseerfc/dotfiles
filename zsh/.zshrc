# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

## config for grml-zsh
if [[ -r "/etc/zsh/keephack" ]]; then
    # grml-zsh unset prompt
    prompt off
    # grml-zsh unset aliases
    unalias lsd
    unset -f trans
fi


POWERLINE_BINDINGS=/usr/share/powerline/bindings/
## load powerlevel10k or powerline or pure whichever installed
if [[ -r "$HOME/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    # config for powerlevel10k
    source ~/powerlevel10k/powerlevel10k.zsh-theme
    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
elif [[ -r "/usr/share/zsh/functions/Prompts/prompt_pure_setup" ]]; then
    ## config for pure
    autoload -U promptinit; promptinit
    prompt pure
elif [[ -r "$POWERLINE_BINDINGS/zsh/powerline.zsh" ]]; then
    ## config for powerline
    powerline-daemon -q  # run powerline daemon
    source $POWERLINE_BINDINGS/zsh/powerline.zsh
fi

export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
export ZSH_AUTOSUGGEST_USE_ASYNC=true

_ZSH_PLUGINS="/usr/share/zsh/plugins"
for _zsh_plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search; do
   [[ ! -r "$_ZSH_PLUGINS/$_zsh_plugin/$_zsh_plugin.zsh" ]] || source $_ZSH_PLUGINS/$_zsh_plugin/$_zsh_plugin.zsh
done


# key bindings fixes for urxvt
bindkey "^[[7~" beginning-of-line
bindkey "^[[8~" end-of-line
bindkey "^[[5~" beginning-of-history
bindkey "^[[6~" end-of-history
bindkey "^[[3~" delete-char
bindkey "^[[2~" quoted-insert

bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

bindkey "^[p" up-line-or-search
bindkey "^[n" down-line-or-search

bindkey "^[OA" history-substring-search-up
bindkey "^[OB" history-substring-search-down
bindkey "^[0A" history-substring-search-up
bindkey "^[0B" history-substring-search-down

[ -f $HOME/.bashrc ] && source $HOME/.bashrc
[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local
export SHELL=/bin/zsh

## for compdef
autoload -Uz compinit
compinit

# completion for Syu
compdef -e "words[1]=(pacman -Su);service=pacman;((CURRENT+=1));_pacman" Syu Ge Gc Gw
compdef -e "words[1]=(pikaur -G);service=cower;((CURRENT+=1));_pikaur" Ga
compdef -e "words[1]=(pikaur -Ssa);service=cower;((CURRENT+=1));_pikaur" Ssa

# add a command line to the shells history without executing it
commit-to-history () {
        print -s ${(z)BUFFER}
        zle send-break
}
zle -N commit-to-history
bindkey -M viins "^x^h" commit-to-history
bindkey -M emacs "^x^h" commit-to-history


# zsh_stats from oh-my-zsh https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/functions.zsh
function zsh_stats() {
  fc -l 1 | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n20
}

# set end of file mark
export PROMPT_EOL_MARK="%B%F{red}🔚"

() { # TIMEFMT {{{3
  local white_b=$'\e[97m' blue=$'\e[94m' rst=$'\e[0m'
  TIMEFMT=("== TIME REPORT FOR $white_b%J$rst =="$'\n'
    "  User: $blue%U$rst"$'\t'"System: $blue%S$rst  Total: $blue%*Es${rst}"$'\n'
    "  CPU:  $blue%P$rst"$'\t'"Mem:    $blue%M MiB$rst")
}

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

