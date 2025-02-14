[ -z "$_bashrc_sourced" ] || return 1
_bashrc_sourced=1

source ~/.profile || true
# Source default .bashrc
if [ -f /etc/skel/.bashrc ]; then
    source /etc/skel/.bashrc
fi
unset _bashrc_sourced

# Non-color prompt
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

export PYTHONDONTWRITEBYTECODE=1
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
export NODE_PATH=~/.local/lib/node_modules
export LC_COLLATE=C

alias grep="grep --color"
alias rm="rm -I"
alias mv="mv -i"
alias cp="cp -i"
if command -v tmux > /dev/null; then
    alias tmux="tmux -2"
fi
if command -v git > /dev/null; then
    alias git="FILTER_BRANCH_SQUELCH_WARNING=1 git"
fi
if command -v pycodestyle > /dev/null; then
    alias pep8=pycodestyle
fi
if command -v yad > /dev/null; then
    alias yad="yad --splash"
fi
if command -v ncal > /dev/null; then
    alias cal="ncal -C"
fi
if command -v mail > /dev/null; then
    alias mail="MBOX=$HOME/Documents/mbox mail"
fi
alias less="less -F"

get-alias() {
    local def
    if ! def=$(alias "$1" 2> /dev/null); then
        printf '%s\n' "$1"
        return 0
    fi
    eval "def=${def#*=}"
    printf '%s\n' "$def"
}

# Replaces `-h` with `--si`.
si() {
    local cmd=$1
    shift
    local done
    local arg
    for arg do
        shift
        [ -n "${done-}" ] || case "$arg" in
            --) done=1 ;;
            --*) ;;
            -*h*)
                case "$cmd" in
                    free) ;;
                    *) arg=${arg%%h*}${arg#*h} ;;
                esac
                if [ "$arg" != - ]; then
                    set -- "$@" "$arg"
                fi
                set -- "$@" --si
                continue
                ;;
        esac
        set -- "$@" "$arg"
    done
    "$cmd" "$@"
}

alias ls="si $(get-alias ls)"
alias du="si $(get-alias du)"
alias df="si $(get-alias df)"
alias free="si $(get-alias free)"

gccs() {
    gcc -std=c11 -Wall -Wextra -Werror -pedantic -Og "$@"
}

g++s() {
    g++ -std=c++17 -Wall -Wextra -pedantic -Og "$@"
}

clang++s() {
    clang++ -std=c++17 -Wall -Wextra -pedantic -Og "$@"
}

g++i() {
    g++s "$@" -fdiagnostics-color=always |& less -R
}

clang++i() {
    clang++s "$@" -fdiagnostics-color=always |& less -R
}

clear-history() {
    history -wc
    rm -f ~/.*_history
    rm -f ~/.viminfo
    rm -f ~/.vimclip
    rm -f ~/.vim/.netrwhist
    rm -f ~/.lesshst
}

clear-clipboard() {
    local c
    for c in p s b; do
        xsel "-$c" < /dev/null
    done
}

clear-all() {
    clear-history
    clear-clipboard
}

cd-parent() {
    cd "$(realpath ..)"
}

ansireset() {
    printf '\033[0m'
}

if [ -x ~/scripts/keyboard.sh ]; then keyboard() {
    ~/scripts/keyboard.sh "$@"
} fi

if [ -x ~/scripts/mouse.sh ]; then mouse() {
    ~/scripts/mouse.sh
} fi

if [ -x ~/scripts/controls.sh ]; then controls() {
    ~/scripts/controls.sh
} fi

if [ -x ~/scripts/displays.sh ]; then displays() {
    ~/scripts/displays.sh
} fi

git-gc-all() {
    if [ "$1" != "--confirm" ]; then
        echo >&2 "error: pass --confirm to confirm"
        return 1
    fi
    shift
    # https://stackoverflow.com/a/14729486
    git -c gc.reflogExpire=0 -c gc.reflogExpireUnreachable=0 \
        -c gc.rerereresolved=0 -c gc.rerereunresolved=0 \
        -c gc.pruneExpire=now gc "$@"
}

unset -f rg
if command -v rg > /dev/null; then
    rg() {
        command rg -p "$@" | less -R
    }

    rgg() {
        rg -. '-g!.git' "$@"
    }
fi

unset -f cargo
if command -v cargo > /dev/null; then cargo() {
    if ! command cargo --version |
        sed 's/[^A-Za-z]/ /g;s/.*/ & /' |
        grep -q ' nightly '
    then
        command cargo "$@"
        return
    fi

    local rf=$RUSTFLAGS
    local rdf=$RUSTDOCFLAGS
    local mf=$MIRIFLAGS
    rf="$rf -Z macro-backtrace -Z proc-macro-backtrace"
    rdf="$rdf -Z unstable-options"
    mf="$mf -Zmiri-symbolic-alignment-check -Zmiri-strict-provenance"

    case "$1" in
        test)
            # Necessary to use local std docs
            rdf="$rdf --extern-html-root-takes-precedence"
            ;;
        doc)
            set -- "$@" -Zrustdoc-map -Zrustdoc-scrape-examples
            ;;
    esac
    RUSTFLAGS=$rf RUSTDOCFLAGS=$rdf MIRIFLAGS=$mf command cargo "$@"
} fi

if command -v ds > /dev/null; then
    complete -F _command ds
fi
