" Copyright (C) 2023, 2025 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

set matchpairs+=`:'
set cpoptions+=%M

let s:startquote = "`"
let s:endquote = "'"
let s:modeline_found = 0

function s:Escape(string)
    return substitute(a:string, '["\\]', '\\\0', '')
endfunction

function s:ChangeQuote(startquote, endquote)
    let startquote = s:Escape(a:startquote)
    let endquote = s:Escape(a:endquote)
    syn clear m4String
    if startquote != "" && endquote != ""
        execute 'syn region m4String start="' . startquote . '" end="'
            \ . endquote . '" contains=m4Constants,m4Special,m4Variable,'
            \ . 'm4Command,m4Statement,m4Function,m4String'
    endif
endfunction

command -nargs=* M4ChangeQuote call s:ChangeQuote(<f-args>)

function s:ParseLine(n)
    let line = getline(a:n)
    let opts = substitute(line, '.*\<vim-m4:\s*', '', '')
    if opts == line
        return
    endif
    let s:modeline_found = 1
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

if !s:modeline_found && search('\<changequote(', 'cnw', 0, 500) > 0
    let s:startquote = ""
    let s:endquote = ""
endif
call s:ChangeQuote(s:startquote, s:endquote)
