#
# ~/.bashrc
#

# If not running interactively, don't do anything

export PATH=$PATH:~/eclipse:/usr/local/texlive/2015/bin/x86_64-linux:/usr/lib/ruby/gems/2.0.0/bin:/home/farseerfc/.gem/ruby/2.0.0/bin:~/.cabal/bin:~/.cargo/bin
export MANPATH=$MANPATH:/usr/local/texlive/2015/texmf/doc/ma
export INFOPATH=$INFOPATH:/usr/local/texlive/2015/texmf/doc/info
export QT_PLUGIN_PATH=$QT_PLUGIN_PATH:/usr/lib/qt4/plugins:/usr/lib/kde4/plugins

[[ $- != *i* ]] && return

alias ls='ls --color=auto'

alias ll='ls -l'
alias la='ls -la'
alias lh='ls -lh'
alias grep='grep --color'
alias g="git annex"
alias k="kde-open"
alias x="xdg-open"
export LESS="-R"

alias start="sudo systemctl start"
alias stop="sudo systemctl stop"
alias restart="sudo systemctl restart"
alias .="source"
alias cp="cp -i --reflink=auto"
alias bc="bc -l"

alias gtar="tar -Ipigz czfv"
alias btar="tar -Ilbzip2 cjfv"
alias 7tar="7z a -mmt" 
alias xcp="rsync -aviHAXKhP --delete --exclude='*~' --exclude=__pycache__"

man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;37m") \
		LESS_TERMCAP_md=$(printf "\e[1;37m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;47;30m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[0;36m") \
			man "$@"
}


function _git_prompt() {
    local git_status="`git status -unormal 2>&1`"
    if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local ansi=42
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local ansi=43
        else
            local ansi=45
        fi
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=${BASH_REMATCH[1]}
            test "$branch" != master || branch=' '
        else
            # Detached HEAD.  (branch=HEAD is a faster alternative.)
            branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
                echo HEAD`)"
        fi
        echo -n '\[\e[0;37;'"$ansi"';1m\]'"$branch"'\[\e[0m\] '
    fi
}
function _prompt_command() {
    PS1="`_git_prompt`"'\[\e[1;32m\]\u\[\e[m\]\[\e[0;32m\]@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;32m\]\$\[\e[m\] '
}
PROMPT_COMMAND=_prompt_command

function bbscp(){
src-hilite-lesspipe.sh $@ | \
sed 's/'$(echo -e "\033")'/'`echo -e "\033\033"`'/g' | \
tee /dev/tty | xsel -bi
}
function wiki(){
dig +short txt $@.wp.dg.cx
}
function wifi(){
sudo bash -c "wpa_passphrase $2 $3 | wpa_supplicant -Dwext -i$1 -c/dev/stdin &"
sleep 5
sudo dhcpcd $1
}

LS_COLORS='rs=0:di=01;94:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS
PAGER='less -X -M' export LESSOPEN="| pygmentize -f console -O bg=dark %s" export LESS=' -R '

EDITOR="vim"
export EDITOR

# added by travis gem
[ -f /home/farseerfc/.travis/travis.sh ] && source /home/farseerfc/.travis/travis.sh
