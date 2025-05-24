[ -z "$_profile_sourced" ] || return 1
_profile_sourced=1
unalias -a

[ -n "${ORIG_PATH+x}" ] || export ORIG_PATH=$PATH
PATH=$ORIG_PATH

export GOPATH=~/go
PATH=$GOPATH/bin:$PATH
PATH=~/.virtualenv/bin:$PATH
export PYENV_ROOT=~/.pyenv
export PYENV_DIR=~
PATH=$PYENV_ROOT/bin:$PATH
PATH=~/.cargo/bin:$PATH
PATH=~/.local/bin:$PATH
PATH=~/bin:$PATH

delayed_exec() {
    local timeout=5
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h|--help)
                cat << EOF
Usage: delayed-exec [--timeout=<seconds>] [command [args...]]
EOF
                return 0
                ;;
            --timeout)
                if [ "$#" -lt 2 ]; then
                    printf >&2 '%s\n' "error: missing argument for $1"
                    return 1
                fi
                timeout=$2
                shift
                ;;
            --timeout=*)
                timeout=${1#*=}
                ;;
            --)
                shift
                break
                ;;
            -*)
                printf >&2 '%s\n' "error: unrecognized option: $1"
                return 1
                ;;
            *)
                break
                ;;
        esac
        shift
    done
    case "$timeout" in
        *[!0-9.]*|*.*.*|.|"")
            printf >&2 '%s\n' "error: invalid timeout: '$timeout'"
            return 1
            ;;
    esac
    [ "$#" -gt 0 ] || return 0
    local start_time=$(awk '{ print $1 }' /proc/uptime)
    "$@" && true
    local status=$?
    if awk -- '
        BEGIN { ARGC = 2 }
        { exit $1 - ARGV[2] < ARGV[3] ? 0 : 1 }
    ' /proc/uptime "$start_time" "$timeout"; then
        return "$status"
    fi
    exit "$status"
}

alias delayed-exec=delayed_exec

source_bashrc() {
    unset -f source_bashrc
    # if running bash
    if [ -n "$BASH_VERSION" ]; then
        # include .bashrc if it exists
        if [ -f "$HOME/.bashrc" ]; then
            . "$HOME/.bashrc" || true
        fi
    fi
    unset _profile_sourced
}

# If this file is used as a shared script that other .profile files source, it
# may be desired to defer the sourcing of .bashrc so those other files can run
# their own commands first.
[ -n "$DEFER_BASHRC" ] || source_bashrc
