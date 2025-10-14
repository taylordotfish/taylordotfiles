" Modified from rust.vim: https://github.com/rust-lang/rust.vim
syn region rustMacroRepeat matchgroup=rustMacroRepeatDelimiters
    \ start="$(" end="),\=[*+?]" contains=TOP
