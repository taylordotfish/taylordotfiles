" Copyright (C) 2023, 2025 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later
set matchpairs+=`:'
set cpoptions+=%M
let s:startquote="`"
let s:endquote="'"

function s:ParseLine(n)
    let line = getline(a:n)
    let opts = substitute(line, '.*\<vim-m4:\s*', '', '')
    if opts == line
        return
    endif
    let startquote = substitute(opts, '.*\<startquote=\(\S*\).*', '\1', '')
    if startquote != opts
        let s:startquote = startquote
    endif
    let endquote = substitute(opts, '.*\<endquote=\(\S*\).*', '\1', '')
    if endquote != opts
        let s:endquote = endquote
    endif
endfunction

let s:i = 1
while s:i <= min([&l:modelines, line("$")])
    call s:ParseLine(s:i)
    let s:i += 1
endwhile
let s:i = max([s:i, line("$") - &l:modelines + 1])
while s:i <= line("$")
    call s:ParseLine(s:i)
    let s:i += 1
endwhile

syn clear m4String
if s:startquote != "" && s:endquote != ""
    execute 'syn region m4String start="' . s:startquote . '" end="'
        \ . s:endquote . '" contains=m4Constants,m4Special,m4Variable,'
        \ . 'm4Command,m4Statement,m4Function,m4String'
endif
