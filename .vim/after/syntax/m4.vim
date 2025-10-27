" Copyright (C) 2023, 2025 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

setlocal matchpairs+=`:'
setlocal cpoptions+=%M

function s:Escape(string)
    return '\V' . substitute(a:string, '["\\]', '\\\0', '')
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

command -nargs=+ M4ChangeQuote call s:ChangeQuote(<f-args>)

function s:ParseLine(n, state)
    let line = getline(a:n)
    let opts = substitute(line, '.*\<vim-m4:\s*', '', '')
    if opts == line
        return
    endif
    let a:state.modeline_found = 1
    let startquote = substitute(opts, '.*\<startquote=\(\S*\).*', '\1', '')
    if startquote != opts
        let a:state.startquote = startquote
    endif
    let endquote = substitute(opts, '.*\<endquote=\(\S*\).*', '\1', '')
    if endquote != opts
        let a:state.endquote = endquote
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
