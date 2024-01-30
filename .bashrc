[ -n "$SOURCED_FROM_BASHRC" ] && return 1
unalias -a

SOURCED_FROM_BASHRC=1 source ~/.profile || true
# Source default .bashrc
source /etc/skel/.bashrc

# Non-color prompt
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

export PYTHONDONTWRITEBYTECODE=1
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
export MIRIFLAGS="-Zmiri-symbolic-alignment-check -Zmiri-strict-provenance"
export NODE_PATH=~/.local/lib/node_modules

alias grep="grep --color"
alias rm="rm -I"
alias mv="mv -i"
alias cp="cp -i"
alias tmux="tmux -2"
alias git="FILTER_BRANCH_SQUELCH_WARNING=1 git"
alias pep8=pycodestyle
alias yad="yad --splash"
alias cal="ncal -C"
alias mail="MBOX=$HOME/Documents/mbox mail"

get-alias() {
    printf '%s' "${BASH_ALIASES[$1]-$1}"
}

# Adds the option "--si" to a command if "-h" is present.
si() {
    local arg
    for arg in "${@:2}"; do
        if [[ "$arg" != --* ]] && [[ "$arg" == -*h* ]]; then
            "$@" --si
            return
        fi
    done
    "$@"
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
    g++s "$@" -fdiagnostics-color=always |& less -FR
}

clang++i() {
    clang++s "$@" -fdiagnostics-color=always |& less -FR
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
        printf '' | xsel "-$c"
    done
}

clear-all() {
    clear-history && clear-clipboard
}

cd-parent() {
    cd "$(realpath ..)"
}

ansireset() {
    printf '\033[0m'
}

[ -f ~/scripts/keyboard.sh ] && keyboard() {
    ~/scripts/keyboard.sh "$@"
}

[ -f ~/scripts/mouse.sh ] && mouse() {
    ~/scripts/mouse.sh
}

[ -f ~/scripts/controls.sh ] && controls() {
    ~/scripts/controls.sh
}

[ -f ~/scripts/displays.sh ] && displays() {
    ~/scripts/displays.sh
}

git-gc-all() {
    if [ "$1" != "--confirm" ]; then
        echo >&2 "error: pass --confirm to confirm"
        return 1
    fi
    # https://stackoverflow.com/a/14729486
    git -c gc.reflogExpire=0 -c gc.reflogExpireUnreachable=0 \
        -c gc.rerereresolved=0 -c gc.rerereunresolved=0 \
        -c gc.pruneExpire=now gc "${@:2}"
}

which rg > /dev/null && rg() {
    env rg -p "$@" | less -FR
}

find-unpushed() {
    local d
    local IFS='
'
    for d in $(find -maxdepth 1 -type d -path './*'); do
        if ! (\
            set -eu
            cd "$d"
            [ -d ".git" ] || exit 0
            branch=$(git rev-parse --abbrev-ref 'HEAD@{upstream}')
            set +e
            git diff --name-only --exit-code "$branch" > /dev/null
            status=$?
            set -e
            [ "$status" -ne 1 ] && exit "$status"
            printf '%s\n' "$d"
        ); then
            printf 'error: %s\n' "$d"
        fi
    done
}

which cargo > /dev/null && cargo() {
    if ! env cargo --version | grep '\bnightly\b' > /dev/null; then
        env cargo "$@"
        return
    fi

    local rustflags=" -Z macro-backtrace -Z proc-macro-backtrace"
    local docflags=" -Z unstable-options"
    # Necessary to use local std docs
    [ "$1" = "test" ] || docflags+=" --extern-html-root-takes-precedence"

    local args=()
    [ "$1" = "doc" ] && args+=(-Zrustdoc-map -Zrustdoc-scrape-examples)
    RUSTFLAGS="$RUSTFLAGS ${rustflags:1}" \
    RUSTDOCFLAGS="$RUSTDOCFLAGS ${docflags:1}" \
        env cargo "$@" "${args[@]}"
}
