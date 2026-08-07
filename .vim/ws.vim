" ws.vim: whitespace/indent configuration
" Copyright (C) 2023-2026 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

function s:SetIndent(amount)
    let &l:shiftwidth = a:amount
    let &l:tabstop = a:amount
endfunction

function s:GetCIndent()
    let l:line = prevnonblank(v:lnum - 1)
    if l:line == 0
        return 0
    endif
    " Increase indent after first line ending with backslash
    if getline(l:line) !~ '\\$'
        return cindent(v:lnum)
    endif
    let l:prev = prevnonblank(l:line - 1)
    if getline(l:prev) =~ '\\$'
        return indent(l:line)
    endif
    return indent(l:line) + &shiftwidth
endfunction

command -nargs=1 SetIndent call s:SetIndent(<f-args>)
command ResetIndent setlocal indentexpr=
command UseCIndent setlocal indentexpr=s:GetCIndent()

" Call this function in FileType autocommands to set options. `options` is a
" dictionary containing any subset of the following items:
"
" - mode: 'space' (default) or 'tab'
" - ft_indent: whether to use filetype-based indenting (default: 1)
function g:WsSetFileOptions(options)
    if !exists("b:ws_state")
        let b:ws_state = #{}
    endif
    for l:opt in ["mode", "ft_indent"]
        if has_key(a:options, l:opt)
            let b:ws_state[l:opt] = a:options[l:opt]
        endif
    endfor
endfunction

function s:SetMode(mode)
    call g:WsSetFileOptions(#{mode: a:mode})
    call s:Refresh()
endfunction

" For files primarily indented with tabs
command TabMode call s:SetMode("tab")
" For files primarily indented with spaces
command SpaceMode call s:SetMode("space")

au InsertEnter * execute "setlocal listchars-=" . w:ws_state.lc_normal
au InsertLeave * execute "setlocal listchars+=" . w:ws_state.lc_normal

function s:EnableTrailing()
    if g:fancyterm && w:ws_state.trailing_id is v:null
        let w:ws_state.trailing_id = matchadd("TrailingWs", '\s\+$', -1)
    endif
endfunction

function s:DisableTrailing()
    if w:ws_state.trailing_id isnot v:null
        call matchdelete(w:ws_state.trailing_id)
        let w:ws_state.trailing_id = v:null
    endif
endfunction

if g:fancyterm
    " Highlight trailing space
    hi def link Ws NonText
    hi def link TrailingWs Todo
    hi def link InternalTab TrailingWs
    au InsertEnter * call s:DisableTrailing()
    au InsertLeave * call s:EnableTrailing()
endif

function s:IsInitialized()
    return exists("b:ws_state.ft")
endfunction

function s:Init()
    if !exists("w:ws_state")
        let w:ws_state = #{
            \ mode: v:null,
            \ ws_ids: [],
            \ lc_normal: v:null,
            \ trailing_id: v:null,
        \ }
        call s:EnableTrailing()
    endif

    if !s:IsInitialized()
        if !exists("b:ws_state")
            let b:ws_state = #{}
        endif
        let b:ws_state = extend(
            \ #{mode: "space", ft_indent: 1, ft: v:null},
            \ b:ws_state,
        \ )
    endif

    if b:ws_state.ft isnot# &ft
        let b:ws_state.ft = &ft
        if &ft is# "" || !b:ws_state.ft_indent
            ResetIndent
        elseif &indentexpr is# ""
            UseCIndent
        endif
        " `list` and `listchars` are documented as being window-local rather
        " than buffer-local, but this doesn't seem to be the case.
        if &ft is# "help"
            setlocal nolist
        else
            setlocal list
        endif
        setlocal listchars=extends:$,precedes:$
    endif

    if w:ws_state.mode isnot# b:ws_state.mode
        for l:id in w:ws_state.ws_ids
            call matchdelete(l:id)
        endfor
        let w:ws_state.ws_ids = []

        let l:mode = b:ws_state.mode
        if l:mode == "tab"
            call s:InitTab()
        elseif l:mode == "space"
            call s:InitSpace()
        else
            echoerr "unknown mode: " . l:mode
        endif
        let w:ws_state.mode = l:mode
    endif
endfunction

function s:InitTab()
    setlocal noexpandtab softtabstop=0
    if g:term_encoding is# "utf8"
        let l:spacechar="·"
    else
        let l:spacechar="`"
    endif
    let l:lc_normal = "trail:" . l:spacechar
    execute 'setlocal listchars+=tab:\ \ ,lead:' . l:spacechar . ","
        \ . l:lc_normal
    let w:ws_state.lc_normal = l:lc_normal
    if g:fancyterm
        let l:ws_ids = w:ws_state.ws_ids
        call add(l:ws_ids, matchadd("Ws", '\%(^\s*\)\@<= ', -2))
        call add(l:ws_ids, matchadd("Ws", ' \ze\s*$', -2))
        call add(l:ws_ids, matchadd("InternalTab", '\%(\S.*\)\@<=\t', -1))
    endif
endfunction

function s:InitSpace()
    let &l:expandtab = 1
    if &softtabstop == 0
        let &l:softtabstop = &shiftwidth
    endif
    let w:ws_state.lc_normal = ""
    if !g:term_encoding is# "utf8"
        let l:tabchars='\|-\|'
    elseif $HEAVY_BLOCKS isnot# ""
        let l:tabchars="┣━┫"
    else
        let l:tabchars="├─┤"
    endif
    execute "setlocal listchars+=tab:" . l:tabchars
    if g:fancyterm
        let l:ws_ids = w:ws_state.ws_ids
        call add(l:ws_ids, matchadd("Ws", '\t', -2))
    endif
endfunction

function s:Refresh()
    if s:IsInitialized()
        call s:Init()
    endif
endfunction

au BufEnter * call s:Init()
au FileType * call s:Refresh()
