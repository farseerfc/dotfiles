#
# ~/.bashrc
#


TEXLIVEPATH=/usr/local/texlive/2016

export PATH=$PATH:~/eclipse:$TEXLIVEPATH/bin/x86_64-linux:/usr/lib/ruby/gems/2.0.0/bin:~/.gem/ruby/2.0.0/bin:~/.cabal/bin:~/.cargo/bin:~/.local/bin:~/.npm-global/bin:~/go/bin
export MANPATH=$MANPATH:$TEXLIVEPATH/texmf/doc/ma
export INFOPATH=$INFOPATH:$TEXLIVEPATH/texmf/doc/info
export QT_PLUGIN_PATH=$QT_PLUGIN_PATH:/usr/lib/qt4/plugins:/usr/lib/kde4/plugins
export PYTHONPATH=$PYTHONPATH:~/github/winterpy/pylib


# perl path added by cpan
PATH="/home/farseerfc/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/farseerfc/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/farseerfc/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/farseerfc/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/farseerfc/perl5"; export PERL_MM_OPT;

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
alias ls='exa -gb'

alias lsd='exa -gb --icons'
alias ll='lsd -l'
alias la='lsd -laa'
alias lh='lsd -lh'
alias lah='lsd -lah'
alias grep='grep --color'
alias ip='ip -c=auto'
alias g="git-annex"
alias k="kde-open5"
alias x="xdg-open"

alias start="sudo systemctl start"
alias stop="sudo systemctl stop"
alias restart="sudo systemctl restart"

alias .="source"
alias cp="cp -i --reflink=auto --sparse=auto"
alias ssh="TERM=xterm-256color ssh"
alias bc="bc -lq"
alias numsum="tr '\n' '+' | sed 's/\+$/\n/' | bc"
alias pvb="pv -W -F'All:%b In:%t Cu:%r Av:%a %p'"
alias kwin-blur="xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0"
alias kwin-clear="xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -remove _KDE_NET_WM_BLUR_BEHIND_REGION"
alias gtar="tar -Ipigz czfv"
alias btar="tar -Ilbzip2 cjfv"
alias 7tar="7z a -mmt" 
alias xcp="rsync -aviHAXKhP --delete --exclude='*~' --exclude=__pycache__"
alias tmux="tmux -2"
alias :q="exit"
alias :w="sync"
alias :x="sync && exit"
alias :wq="sync && exit"

# pacman aliases and functions
function Syu(){
    sudo pacsync pacman -Sy && sudo pacman -Su $@  && sync -f /
    pacman -Qtdq | ifne sudo pacman -Rcs - && sync -f /
    sudo pacsync pacman -Fy && sync -f /
    pacdiff -o
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
alias F="pacman -F"
alias Fo="pacman -F"
alias Fs="pacman -F"
alias Fx="pacman -Fx"
alias Fl="pacman -Fl"
alias Fy="sudo pacman -Fy"
alias Sy="sudo pacman -Sy"
alias Ssa="paru -Ssa"
alias Sas="paru -Ssa"
alias Sia="paru -Sia"
alias Sai="paru -Sia"

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
    git clone https://github.com/archlinux/svntogit-$1/ -b packages/$3 --single-branch $3
    mv "$3"/trunk/* "$3"
    rm -rf "$3"/{repos,trunk,.git}
}

function Gw() {
    [ -z "$1" ] && echo "usage: Gw <package name> [directory (default to pwd)]: get package file *.pkg.tar.xz from pacman cache" && return 1
    sudo pacman -Sw "$1" && cp /var/cache/pacman/pkg/$1*.pkg.tar.* ${2:-.}
}

function Ge() {
    [ -z "$@" ] && echo "usage: $0 <core/extra package name>: get core/extra package PKGBUILD" && return 1
    for i in $@; do
    	G packages core/extra $i
    done
}

function Gc() {
    [ -z "$@" ] && echo "usage: $0 <community package name>: get community package PKGBUILD" && return 1
    for i in $@; do
    	G community community $i
    done
}

alias rankpacman='sed "s/^#//" /etc/pacman.d/mirrorlist.pacnew | rankmirrors -n 10 - | sudo tee /etc/pacman.d/mirrorlist'

alias limit-run='/usr/bin/time systemd-run --user --pty --same-dir --wait --collect --slice=limit-run.slice '
alias limit-cpu='/usr/bin/time systemd-run --user --pty --same-dir --wait --collect --slice=limit-cpu.slice '
alias limit-mem='/usr/bin/time systemd-run --user --pty --same-dir --wait --collect --slice=limit-mem.slice '

alias urldecode='python3 -c "import sys, urllib.parse as up; print(up.unquote(sys.argv[1]))"'
alias urlencode='python3 -c "import sys, urllib.parse as up; print(up.quote(sys.argv[1]))"'

alias ini2json='python3 -c "import fileinput,json,configparser;c=configparser.ConfigParser(allow_no_value=True);c.read_string('"''"'.join(fileinput.input()));print(json.dumps({s: {k: c[s][k] for k in c[s]} for s in c.sections()}))"'


if ! command -v clip.exe &> /dev/null
then
    alias clipboard="xclip -selection clipboard"
    alias Ci="clipboard -i"
    alias Co="clipboard -o"
    alias Copng="Co -target image/png"
else
    alias clipboard="clip.exe"
    alias Ci="clipboard"
fi

Ct(){
    t=$(mktemp /tmp/furigana-XXXX)
    python -m furigana.furigana $(Co) | sed 's@<ruby><rb>@ :ruby:`@g;s@</rb><rt>@|@g;s@</rt></ruby>@` @g' | sponge $t
    cat $t | tee /dev/tty | perl -pe 'chomp if eof' | Ci
}

fs() {
  curl -s -F "c=@${1:--}" "https://fars.ee/?u=1" | tee /dev/tty | perl -p -e 'chomp if eof' | Ci
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

function unzlib {
    exec 9<&0
    printf "\x1f\x8b\x08\x00\x00\x00\x00\x00" | cat - ${1:-/dev/fd/9}  | gzip -dc
}

function zlib {
    cat ${1:-/dev/stdin} | gzip -c | tail -c +9
}

function inflate {
    exec 9<&0
    printf "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\x00" | cat - ${1:-/dev/fd/9}  | gzip -dc
}

function deflate {
    cat ${1:-/dev/stdin} | gzip -c | tail -c +11
}

function pkgcheck() {
export SHELLCHECK_OPTS="-e SC2164"
## SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.

(
echo "export pkgdir='' srcdir=''"
cat $@
echo ""
echo "export pkgname pkgbase pkgdesc arch pkgver pkgrel license install url"
echo "export source source_x86_64 backup"
echo "export depends makedepends optdepends checkdepends"
echo "export provides conflicts replaces"
echo "export sha256sums sha512sums md5sums"
) | shellcheck -s bash -
}

export LESSOPEN="| pygmentize -f console -O bg=dark %s"
export LESS='R'

EDITOR="vim"
export EDITOR

# S_COLORS for sysstat
export S_COLORS=auto

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
