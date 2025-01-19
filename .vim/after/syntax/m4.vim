" Copyright (C) 2023, 2025 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later
set matchpairs+=`:'
set cpoptions+=%M
syn clear m4String
syn region m4Str start="`" end="'" contains=m4Constants,m4Special,
    \ m4Variable,m4Paren,m4Command,m4Statement,m4Function
syn cluster m4Top add=m4Str
hi def link m4Str String
