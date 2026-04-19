" Working as of Debian trixie, vim 2:9.1.1230-2 (Vim 9.1 with patches 1-948,
" 950-1230, 1242, 1244).

" Fix issue where rust.vim sometimes tries to make lines align with an `if` or
" `fn` inside a string literal.
function s:GetRustIndent()
    let l:line = getline(v:lnum)
    if l:line =~# '^\s*\%({\|}\|where\)\s*$'
        let l:prev = prevnonblank(v:lnum - 1)
        return l:prev > 0 ? indent(l:prev) : 0
    endif
    return GetRustIndent(v:lnum)
endfunction

set indentexpr=s:GetRustIndent()
