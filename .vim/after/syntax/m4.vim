" Copyright (C) 2023, 2025-2026 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

setlocal matchpairs+=`:'
setlocal cpoptions+=%M

function s:Escape(string)
    return '\V' . substitute(a:string, '["\\]', '\\\0', '')
endfunction

function s:ChangeQuote(startquote, endquote)
    let l:has_quotes = a:startquote != "" && a:endquote != ""
    if l:has_quotes
        let l:startquote = s:Escape(a:startquote)
        let l:endquote = s:Escape(a:endquote)
    endif
    if hlexists("m4String")
        " Working as of Debian trixie, vim 2:9.1.1230-2 (Vim 9.1 with patches
        " 1-948, 950-1230, 1242, 1244).
        syn clear m4String
        syn cluster m4StringTop contains=m4Constants,m4Special,m4Variable,
            \ m4String,m4Command,m4Statement,m4Function
        if l:has_quotes
            execute 'syn region m4String start="' . l:startquote . '" end="'
                \ . l:endquote . '" contains=@m4StringTop'
        endif
    elseif hlexists("m4Quoted")
        " Working as of Vim 9.1 with patches 1-2112.
        syn clear m4Quoted
        syn cluster m4QuotedTop contains=m4Quoted,m4ParamZero,m4ParamPos,
            \ m4ParamCount,m4ParamAll,m4ParamBad,m4Constants,m4Command,
            \ m4Statement,m4Function
        if l:has_quotes
            execute 'syn region m4Quoted matchgroup=m4QuoteDelim start="'
                \ . l:startquote . '" end="' . l:endquote
                \ . '" contains=@m4QuotedTop'
        endif
        syn region m4Function matchgroup=m4Type start="\<[[:upper:]_]\+("
            \ end=")" contains=@m4Top containedin=@m4Top
        hi def link m4Quoted Constant
        hi def link m4Type Type
        hi def link m4Disabled Comment
    else
        echoerr "could not patch m4 syntax"
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

function s:FindQuotes(state)
    let l:i = 1
    let l:max = min([&modelines, line("$")])
    while l:i <= l:max
        call s:ParseLine(l:i, a:state)
        let l:i += 1
    endwhile
    let l:i = max([l:i, line("$") - &modelines + 1])
    while l:i <= line("$")
        call s:ParseLine(l:i, a:state)
        let l:i += 1
    endwhile

    if a:state.modeline_found
        return
    endif

    let l:pos = getpos('.')[1:]
    call cursor(1, 1)
    let l:lnum = search('\C\<changequote(', 'cW', 0, 500)
    if l:lnum <= 0
        return
    endif

    let a:state.startquote = ""
    let a:state.endquote = ""
    let l:has_other_quote = search('\C\<changequote(', 'nWz', 0, 500) > 0
    call cursor(l:pos)
    if l:has_other_quote
        return
    endif

    let l:line = getline(l:lnum)
    let l:arg = '\%([^,)`]*\%(`[^`' . "']*'" . '\)\?\)*'
    let l:args = []
    call substitute(
        \ l:line,
        \ '.*\<changequote(\s*\(' . l:arg . '\),\s*\(' . l:arg . '\)).*',
        \ { m -> len(extend(l:args, m[1:2])) },
        \ "",
    \ )

    if empty(l:args)
        return
    endif
    call map(l:args, { _, s -> substitute(s, "`\\([^`']*\\)'", '\1', 'g') })
    let [a:state.startquote, a:state.endquote] = l:args
endfunction

function s:Init()
    let l:state = #{startquote: "`", endquote: "'", modeline_found: 0}
    call s:FindQuotes(l:state)
    call s:ChangeQuote(l:state.startquote, l:state.endquote)
endfunction

call s:Init()
