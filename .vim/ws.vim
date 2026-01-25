" ws.vim: whitespace/indent configuration
" Copyright (C) 2023-2026 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

" FileType autocommands can set these variables:
" - g:ws_config.mode: 'space' or 'tab'
" - g:ws_config.ft_indent: whether to use filetype-based indenting
" By default, `mode` is 'space' and `ft_indent` is 1.

function s:SetDefaults()
    let g:ws_config = #{mode: "space", ft_indent: 1}
endfunction
call s:SetDefaults()

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

" For files primarily indented with tabs
function s:TabMode()
    call s:ClearWsMode()
    setlocal noexpandtab softtabstop=0
    if g:term_encoding == "utf8"
        let l:spacechar="·"
    else
        let l:spacechar="`"
    endif
    let l:lc_normal = "trail:" . l:spacechar
    execute 'setlocal listchars+=tab:\ \ ,lead:' . l:spacechar . ","
        \ . l:lc_normal
    let b:ws_state.lc_normal = l:lc_normal
    if g:fancyterm
        let l:ws_ids = b:ws_state.ws_ids
        call add(l:ws_ids, matchadd("Ws", '\(^\s*\)\@<= ', -2))
        call add(l:ws_ids, matchadd("Ws", ' \ze\s*$', -2))
        call add(l:ws_ids, matchadd("TrailingWs", '\(\S.*\)\@<=\t', -1))
    endif
endfunction
command TabMode call s:TabMode()

" For files primarily indented with spaces
function s:SpaceMode()
    call s:ClearWsMode()
    let &l:expandtab = 1
    if &softtabstop == 0
        let &l:softtabstop = &shiftwidth
    endif
    let b:ws_state.lc_normal = ""
    if !g:term_encoding == "utf8"
        let l:tabchars='\|-\|'
    elseif $HEAVY_BLOCKS != ""
        let l:tabchars="┣━┫"
    else
        let l:tabchars="├─┤"
    endif
    execute "setlocal listchars+=tab:" . l:tabchars
    if g:fancyterm
        let l:ws_ids = b:ws_state.ws_ids
        call add(l:ws_ids, matchadd("Ws", '\t', -2))
    endif
endfunction
command SpaceMode call s:SpaceMode()

function s:ClearWsMode()
    setlocal listchars=extends:$,precedes:$
    for l:id in b:ws_state.ws_ids
        call matchdelete(l:id)
    endfor
    let b:ws_state.ws_ids = []
endfunction

au InsertEnter * execute "setlocal listchars-=" . b:ws_state.lc_normal
au InsertLeave * execute "setlocal listchars+=" . b:ws_state.lc_normal

if g:fancyterm
    " Highlight trailing space
    hi Ws ctermfg=243 cterm=none
    function s:HiTrailingWs()
        hi TrailingWs ctermfg=40 ctermbg=none cterm=reverse
    endfunction
    au InsertEnter * hi clear TrailingWs
    au InsertLeave * call s:HiTrailingWs()
    call s:HiTrailingWs()
endif

function s:Init()
    let b:ws_state = #{ws_ids: []}
    if g:fancyterm
        call matchadd("TrailingWs", '\s\+$', -1)
    endif
    call s:Refresh()
endfunction

function s:Refresh()
    let b:ws_state.ft = &ft
    if &ft == "" || !g:ws_config.ft_indent
        ResetIndent
    elseif &indentexpr == ""
        UseCIndent
    endif
    if &ft == "help"
        setlocal nolist
    else
        setlocal list
    endif
    if g:ws_config.mode == "tab"
        TabMode
    else
        SpaceMode
    endif
    call s:SetDefaults()
endfunction

function s:IsInitialized()
    return exists("b:ws_state.ft")
endfunction

function s:OnBufEnter()
    if !s:IsInitialized()
        call s:Init()
    endif
endfunction

function s:OnFileType()
    if s:IsInitialized() && b:ws_state.ft != &ft
        call s:Refresh()
    endif
endfunction

function s:OnBufUnload()
    if bufnr() == expand("<abuf>")
        let b:ws_state = v:null
    endif
endfunction

au BufEnter * call s:OnBufEnter()
au FileType * call s:OnFileType()
au BufUnload * call s:OnBufUnload()
