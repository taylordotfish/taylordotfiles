" Copyright (C) 2023, 2025 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

setlocal matchpairs+=`:'
setlocal cpoptions+=%M

function s:Escape(string)
    return '\V' . substitute(a:string, '["\\]', '\\\0', '')
endfunction

function s:ChangeQuote(startquote, endquote)
    let l:startquote = s:Escape(a:startquote)
    let l:endquote = s:Escape(a:endquote)
    syn clear m4String
    if l:startquote != "" && l:endquote != ""
        execute 'syn region m4String start="' . l:startquote . '" end="'
            \ . l:endquote . '" contains=m4Constants,m4Special,m4Variable,'
            \ . 'm4Command,m4Statement,m4Function,m4String'
    endif
endfunction

command -nargs=+ M4ChangeQuote call s:ChangeQuote(<f-args>)

function s:ParseLine(n, state)
    let l:line = getline(a:n)
    let l:opts = substitute(l:line, '.*\<vim-m4:\s*', '', '')
    if l:opts == l:line
        return
    endif
    let a:state.modeline_found = 1
    let l:startquote = substitute(l:opts, '.*\<startquote=\(\S*\).*', '\1', '')
    if l:startquote != l:opts
        let a:state.startquote = l:startquote
    endif
    let l:endquote = substitute(l:opts, '.*\<endquote=\(\S*\).*', '\1', '')
    if l:endquote != l:opts
        let a:state.endquote = l:endquote
    endif
endfunction

function s:Init()
    let l:state = #{startquote: "`", endquote: "'", modeline_found: 0}
    let l:i = 1
    while l:i <= min([&modelines, line("$")])
        call s:ParseLine(l:i, l:state)
        let l:i += 1
    endwhile
    let l:i = max([l:i, line("$") - &modelines + 1])
    while l:i <= line("$")
        call s:ParseLine(l:i, l:state)
        let l:i += 1
    endwhile

    if !l:state.modeline_found && search('\<changequote(', 'cnw', 0, 500) > 0
        let l:state.startquote = ""
        let l:state.endquote = ""
    endif
    call s:ChangeQuote(l:state.startquote, l:state.endquote)
endfunction

call s:Init()
