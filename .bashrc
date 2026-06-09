[ -z "$_bashrc_sourced" ] || return 0
_bashrc_sourced=1

. ~/.profile
if [ -f ~/.bashrc.pre ]; then
    . ~/.bashrc.pre
fi
unset -v _bashrc_sourced

PS1='\u@\h:\w\$ '
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
if command -v dircolors > /dev/null; then
    eval "$(dircolors -b)"
fi

export PYTHONDONTWRITEBYTECODE=1
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
export LC_COLLATE=C

alias grep="grep --color=auto"
alias rm="rm -I"
alias mv="mv -i"
alias cp="cp -i"
alias less="less -F --redraw-on-quit"
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

# Replaces `-h` with `--si`.
si() {
    [ "$#" -gt 0 ] || return 1
    local cmd="$1"
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

alias ls="si ls --color=auto"
alias du="si du"
alias df="si df"
alias free="si free"

# Paged version of `ls`.
lsp() {
    if [ -t 1 ]; then
        set -- -C --color=always --quoting-style=shell-escape "$@"
    fi
    set -- si ls -v "$@"
    if [ -t 1 ]; then
        COLUMNS=$(tput cols) "$@" | less -R
    else
        "$@"
    fi
}

_run_gcc_like() {
    local bin="$1"
    shift
    if [ -t 1 ]; then
        command "$bin" -fdiagnostics-color=always "$@" |& less -R
    else
        command "$bin" "$@"
    fi
}

gccs() {
    _run_gcc_like gcc -std=c23 -Wall -Wextra -Werror -pedantic -Og "$@"
}

g++s() {
    _run_gcc_like g++ -std=c++23 -Wall -Wextra -pedantic -Og "$@"
}

clang++s() {
    _run_gcc_like clang++ -std=c++23 -Wall -Wextra -pedantic -Og "$@"
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

if [ -x ~/scripts/controls.sh ]; then controls() {
    ~/scripts/controls.sh
} fi

if [ -x ~/scripts/displays.sh ]; then displays() {
    ~/scripts/displays.sh
} fi

xres() {
    xrdb -cpp m4 ~/.Xresources.m4
}

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

    if [ -f ~/scripts/rgc.sh ]; then rgc() (
        . ~/scripts/rgc.sh
    ) fi
fi

unset -f jq
if command -v jq > /dev/null; then jq() {
    if [ -t 1 ] && ! { [ -t 0 ] && [ "$#" -lt 2 ]; }; then
        command jq -C "$@" | less -R
    else
        command jq "$@"
    fi
} fi

unset -f xxd
if command -v xxd > /dev/null; then xxd() {
    if [ -t 1 ] && ! { [ -t 0 ] && [ "$#" -eq 0 ]; }; then
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

    local rf="$RUSTFLAGS"
    local rdf="$RUSTDOCFLAGS"
    local mf="$MIRIFLAGS"
    rf="$rf -Z macro-backtrace -Z proc-macro-backtrace"
    rdf="$rdf -Z unstable-options --extern-html-root-takes-precedence"
    mf="$mf -Zmiri-symbolic-alignment-check -Zmiri-strict-provenance"

    if [ "$1" = doc ]; then
        set -- "$@" -Zrustdoc-map -Zrustdoc-scrape-examples
    fi
    RUSTFLAGS=$rf RUSTDOCFLAGS=$rdf MIRIFLAGS=$mf command cargo "$@"
} fi

unset -f truncline
if command -v truncline > /dev/null; then truncline() {
    if [ -t 0 ]; then
        command truncline --color=always "$@" | less -R
    else
        command truncline "$@"
    fi
} fi

if command -v profilectl > /dev/null; then
    install-profile() {
        profilectl install "$@"
    }

    remove-profile() {
        profilectl remove "$@"
    }

    load-profile() {
        profilectl load "$@"
    }

    clear-profile() {
        profilectl clear "$@"
    }
fi

if command -v ds > /dev/null; then
    complete -F _command ds
fi

if [ -f ~/.bashrc.post ]; then
    . ~/.bashrc.post
fi
