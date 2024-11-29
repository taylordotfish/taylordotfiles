[ -n "$_profile_sourced" ] && return 1
_profile_sourced=1
[ -z "${ORIG_PATH+x}" ] && export ORIG_PATH=$PATH
PATH=$ORIG_PATH

export GOPATH=~/go
PATH=$GOPATH/bin:$PATH
PATH=~/.virtualenv/bin:$PATH
export PYENV_ROOT=~/.pyenv
PATH=$PYENV_ROOT/bin:$PATH
PATH=~/.cargo/bin:$PATH
PATH=~/.local/bin:$PATH
PATH=~/bin:$PATH

source_bashrc() {
    unset -f source_bashrc
    # if running bash
    if [ -n "$BASH_VERSION" ]; then
        # include .bashrc if it exists
        if [ -f "$HOME/.bashrc" ]; then
            . "$HOME/.bashrc" || true
        fi
    fi
}

# If this file is used as a shared script that other .profile files source, it
# may be desired to defer the sourcing of .bashrc so those other files can run
# their own commands first.
[ -n "$DEFER_BASHRC" ] || source_bashrc
