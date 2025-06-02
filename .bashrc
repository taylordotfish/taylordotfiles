[ -z "$_bashrc_sourced" ] || return 1
_bashrc_sourced=1

source ~/.profile || true
# Source default .bashrc
if [ -f /etc/skel/.bashrc ]; then
    skel_term=$TERM
    # Non-color prompt
    case "$skel_term" in
        *-color|*-256color) skel_term=${skel_term%-*} ;;
    esac
    # Don't set window title
    case "$skel_term" in
        xterm*|rxvt*) skel_term=screen ;;
    esac
    TERM=$skel_term source /etc/skel/.bashrc
    unset skel_term
fi
unset _bashrc_sourced

export PYTHONDONTWRITEBYTECODE=1
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
export NODE_PATH=~/.local/lib/node_modules
export LC_COLLATE=C

alias grep="grep --color"
alias rm="rm -I"
alias mv="mv -i"
alias cp="cp -i"
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
    alias mail="MBOX=~/Documents/mbox mail"
fi
less_args=(-F)
if ! less --version | awk '{
    for (i = 1; i <= NF; ++i)
        if ($(i) ~ /^[0-9]+$/)
            exit $2 < 608 ? 0 : 1
}'; then
    less_args+=(--redraw-on-quit)
fi
alias less="less ${less_args[*]}"
unset less_args

# Replaces `-h` with `--si`.
si() {
    local cmd=$1
    shift
    local done=
    local arg
    for arg do
        shift
        [ -n "$done" ] || case "$arg" in
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

unalias ls 2> /dev/null || true
ls() {
    if [ -t 1 ]; then
        set -- -C --color=always "$@"
    fi
    set -- si command ls -v "$@"
    if [ -t 1 ]; then
        COLUMNS=$(tput cols) "$@" | less -R
    else
        "$@"
    fi
}

alias du="si du"
alias df="si df"
alias free="si free"

_run_gcc_like() {
    local bin=$1
    shift
    if [ -t 1 ]; then
        command "$bin" -fdiagnostics-color=always "$@" |& less -R
    else
        command "$bin" "$@"
    fi
}

gccs() {
    _run_gcc_like gcc -std=c11 -Wall -Wextra -Werror -pedantic -Og "$@"
}

g++s() {
    _run_gcc_like g++ -std=c++17 -Wall -Wextra -pedantic -Og "$@"
}

clang++s() {
    _run_gcc_like clang++ -std=c++17 -Wall -Wextra -pedantic -Og "$@"
}

clear-history() {
    history -c
    rm -f ~/.*_history
    rm -f ~/.viminfo
    rm -f ~/.vimclip
    rm -f ~/.vim/.netrwhist
    rm -f ~/.lesshst
    rm -f ~/.wget-hsts
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

unset -f tree
if command -v tree > /dev/null; then tree() {
    if [ -t 1 ]; then
        command tree -C "$@" | less -R
    else
        command tree "$@"
    fi
} fi

unset -f rg
if command -v rg > /dev/null; then
    rg() {
        if [ -t 1 ]; then
            command rg -p "$@" | less -R
        else
            command rg "$@"
        fi
    }

    rgg() {
        rg -. '-g!.git' "$@"
    }
fi

unset -f jq
if command -v jq > /dev/null; then jq() {
    if [ -t 1 ]; then
        command jq -C "$@" | less -R
    else
        command jq "$@"
    fi
} fi

unset -f xxd
if command -v xxd > /dev/null; then xxd() {
    if [ -t 1 ]; then
        command xxd -Ralways "$@" | less -R
    else
        command xxd "$@"
    fi
} fi

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
