#
# ~/.bashrc
#

# If not running interactively, don't do anything

TEXLIVEPATH=/usr/local/texlive/2016

export PATH=$PATH:~/eclipse:$TEXLIVEPATH/bin/x86_64-linux:/usr/lib/ruby/gems/2.0.0/bin:~/.gem/ruby/2.0.0/bin:~/.cabal/bin:~/.cargo/bin:~/.local/bin:~/.npm-global/bin
export MANPATH=$MANPATH:$TEXLIVEPATH/texmf/doc/ma
export INFOPATH=$INFOPATH:$TEXLIVEPATH/texmf/doc/info
export QT_PLUGIN_PATH=$QT_PLUGIN_PATH:/usr/lib/qt4/plugins:/usr/lib/kde4/plugins

[[ $- != *i* ]] && return

alias ls='ls --color=auto'

alias ll='ls -l'
alias la='ls -la'
alias lh='ls -lh'
alias grep='grep --color'
alias g="git-annex"
alias k="kde-open5"
alias x="xdg-open"
export LESS="-R -N"

alias start="sudo systemctl start"
alias stop="sudo systemctl stop"
alias restart="sudo systemctl restart"
alias .="source"
alias cp="cp -i --reflink=auto"
alias ssh="TERM=xterm-256color ssh"
alias bc="bc -lq"
alias pvb="pv -W -F'All:%b In:%t Cu:%r Av:%a %p'"
alias kwin-blur="xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0"
alias kwin-clear="xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -remove _KDE_NET_WM_BLUR_BEHIND_REGION"

alias gtar="tar -Ipigz czfv"
alias btar="tar -Ilbzip2 cjfv"
alias 7tar="7z a -mmt" 
alias xcp="rsync -aviHAXKhP --delete --exclude='*~' --exclude=__pycache__"
alias tmux="tmux -2"

# pacman aliases and functions
function Syu(){
    sudo pacman -Sy && sudo powerpill -Suw $@ && sudo pacman -Su $@
    pacman -Qtdq | ifne sudo pacman -Rcs -
}

alias Rcs="sudo pacman -Rcs"
alias Ss="pacman -Ss"
alias Si="pacman -Si"
alias Sl="pacman -Sl"
alias Sg="pacman -Sg"
alias Qs="pacman -Qs"
alias Qi="pacman -Qi"
alias Qo="pacman -Qo"
alias Ql="pacman -Ql"
alias Qlp="pacman -Qlp"
alias Qm="pacman -Qm"
alias Qn="pacman -Qn"
alias U="sudo pacman -U"
alias Fo="pacman -Fo"
alias Fl="pacman -Fl"
alias Fy="sudo pacman -Fy"
alias Sy="sudo pacman -Sy"
alias Ssa="cower -c -s"
alias Sas="cower -c -s"
alias Sia="cower -c -i"
alias Sai="cower -c -i"

function Ga() {
    [ -z "$1" ] && echo "usage: Ga <aur package name>: get AUR package PKGBUILD" && return 1
    TMPDIR=$(mktemp -d)
    git clone aur@aur.archlinux.org:"$1".git "$TMPDIR"
    rm -rf "$TMPDIR"/.git
    mkdir -p "$1"
    cp -r -i "$TMPDIR"/* "$1"/
    rm -rf "$TMPDIR"
}

function G() {
    [ -z "$3" ] && echo "usage: $0 <$2 package name>: get $2 package PKGBUILD" && return 1
    git clone https://git.archlinux.org/svntogit/$1.git/ -b packages/$3 --single-branch $3
    mv "$3"/trunk/* "$3"
    rm -rf "$3"/{repos,trunk,.git}
}

function Gw() {
    [ -z "$1" ] && echo "usage: Gw <package name> [directory (default to pwd)]: get package file *.pkg.tar.xz from pacman cache" && return 1
    sudo pacman -Sw "$1" && cp /var/cache/pacman/pkg/$1*.pkg.tar.xz ${2:-.}
}

alias Ge="G packages core/extra"
alias Gc="G community community"

alias rankpacman='sed "s/^#//" /etc/pacman.d/mirrorlist.pacnew | rankmirrors -n 10 - | sudo tee /etc/pacman.d/mirrorlist'

alias urldecode='python2 -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])"'
alias urlencode='python2 -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])"'
imgvim(){
    curl -F "name=@$1" https://img.vim-cn.com/
}

simg(){
    scrot $@ -e 'curl -F \"name=@$f\" https://img.vim-cn.com/'
}

alias pvim="curl -F 'vimcn=<-' https://cfp.vim-cn.com/"

fs() {
  curl -s -F "c=@${1:--}" "https://fars.ee/?u=1" | tee /dev/tty | perl -p -e 'chomp if eof' | xclip -i -selection clipboard
}


alias clipboard="xclip -selection clipboard"
alias Ci="clipboard -i"
alias Co="clipboard -o"

tcn() {
    curl "http://api.t.sina.com.cn/short_url/shorten.json?source=2333871470&url_long=$1"
}

dsf(){
    # depends on diff-so-fancy
    git diff --color=always $@ | diff-so-fancy | less
}

aha-pipe() {
    $@ | ansi2html -m -t "$*" | sed '/.ansi2html-content {/a .ansi2html-content {font-family: monospace;}'
}

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

ga-ncdu() {
    OUTPUT=$(ga-ncdu.pl ${1=.})
    echo -n $OUTPUT | ncdu -f-
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

function wiki(){
    dig +short txt $@.wp.dg.cx
}

function wifi(){
    [ -z "$1" -o -z "$2" -o -z "$3" ] && echo -e "usage: wifi <interface> <ssid> <password>: connect to <ssid> at <interface> using <password>" && return 1
    sudo bash -c "wpa_passphrase $2 $3 | wpa_supplicant -Dwext -i$1 -c/dev/stdin &"
    sleep 5
    sudo dhcpcd $1
}

function compresspdf(){
gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=setting -sOutputFile=$2 $1
}

LS_COLORS='rs=0:di=01;94:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS
PAGER='less -X -M' export LESSOPEN="| pygmentize -f console -O bg=dark %s" export LESS=' -R '

EDITOR="vim"
export EDITOR

function ranger-cd {
    tempfile="$(mktemp)"
    /usr/bin/ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
}

# added by travis gem
[ -f /home/farseerfc/.travis/travis.sh ] && source /home/farseerfc/.travis/travis.sh
