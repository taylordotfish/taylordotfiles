[ -n "$SOURCED_FROM_PROFILE" ] && return 1
. /etc/profile

export GOPATH="$HOME/go"
PATH=$GOPATH/bin:$PATH
export PYENV_ROOT="$HOME/.pyenv"
PATH=$PYENV_ROOT/bin:$PATH
PATH=~/.cargo/bin:$PATH
PATH=~/.local/bin:$PATH
PATH=~/bin:$PATH

source_bashrc() {
    # if running bash
    if [ -n "$BASH_VERSION" ]; then
        # include .bashrc if it exists
        if [ -f "$HOME/.bashrc" ]; then
            SOURCED_FROM_PROFILE=1 . "$HOME/.bashrc" || true
        fi
    fi
}
