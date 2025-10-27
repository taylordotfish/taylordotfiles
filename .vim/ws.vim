" Copyright (C) 2023-2025 taylor.fish <contact@taylor.fish>
" License: GNU GPL version 3 or later

function s:SetDefaults()
    let s:indent = 4
    let s:textwidth = 79
    let s:mode = "space"
    let s:ft_indent = 1 " Whether to use filetype-based indenting
endfunction
call s:SetDefaults()

au FileType make,lua let s:mode = "tab"
au FileType markdown,text,gitcommit let s:ft_indent = 0
let g:python_indent = #{open_paren: s:indent, continue: s:indent}

function s:SetIndent(amount)
    execute "setlocal shiftwidth=" . a:amount
    execute "setlocal softtabstop=" . a:amount
    execute "setlocal tabstop=" . a:amount
endfunction

function s:SetTextWidth(width)
    execute "set textwidth=" . a:width
    execute "set colorcolumn=" . (a:width + 1)
endfunction

function s:SetFtIndent()
    if !s:ft_indent
        ResetIndent
    elseif &indentexpr == ""
        UseCIndent
    endif
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

command ResetIndent setlocal indentexpr=
command UseCIndent setlocal indentexpr=s:GetCIndent()

" For files primarily indented with tabs
function s:TabMode()
    call s:ClearWsMode()
    set noexpandtab softtabstop=0
    if g:lang_utf8
        let spacechar="·"
    else
        let spacechar="`"
    endif
    let l:lc_normal = "trail:" . spacechar
    execute 'setlocal listchars+=tab:\ \ ,lead:' . spacechar . ","
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
    execute "setlocal expandtab softtabstop=" . s:indent
    let b:ws_state.lc_normal = ""
    if !g:lang_utf8
        let tabchars='\|-\|'
    elseif $HEAVY_BLOCKS != ""
        let tabchars="┣━┫"
    else
        let tabchars="├─┤"
    endif
    execute "setlocal listchars+=tab:" . tabchars
    if g:fancyterm
        let l:ws_ids = b:ws_state.ws_ids
        call add(l:ws_ids, matchadd("Ws", '\t', -2))
    endif
endfunction
command SpaceMode call s:SpaceMode()

function s:ClearWsMode()
    set listchars=extends:$,precedes:$
    for id in b:ws_state.ws_ids
        call matchdelete(id)
    endfor
    let b:ws_state.ws_ids = []
endfunction

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
    call s:SetIndent(s:indent)
    call s:SetTextWidth(s:textwidth)
    call s:SetFtIndent()
    if s:mode == "tab"
        TabMode
    else
        SpaceMode
    endif
    call s:SetDefaults()
endfunction

au InsertEnter * execute "setlocal listchars-=" . b:ws_state.lc_normal
au InsertLeave * execute "setlocal listchars+=" . b:ws_state.lc_normal

function s:OnBufEnter()
    if !exists("b:ws_state")
        call s:Init()
    endif
endfunction

function s:OnFileType()
    if exists("b:ws_state") && b:ws_state.ft != &ft
        call s:Refresh()
    endif
endfunction

au BufEnter * call s:OnBufEnter()
au FileType * call s:OnFileType()
