" Working as of Debian trixie, vim 2:9.1.1230-2 (Vim 9.1 with patches 1-948,
" 950-1230, 1242, 1244).

" Fix issue where rust.vim sometimes tries to make lines align with an `if` or
" `fn` inside a string literal.
function s:GetRustIndent()
    let l:line = getline(v:lnum)
    let l:indent = GetRustIndent(v:lnum)

    if l:line !~# '^\s*\%({\|}\|where\)\s*$'
        return l:indent
    endif

    let l:prev = prevnonblank(v:lnum - 1)
    if l:prev <= 0
        return l:indent
    endif

    let l:prev_indent = indent(l:prev)
    if getline(l:prev) =~# '[[{(]\s*$'
        let l:expected_indent = l:prev_indent + &shiftwidth
    else
        let l:expected_indent = l:prev_indent
    endif

    if l:line =~# '}\s*$'
        let l:expected_indent -= &shiftwidth
    endif

    let l:expected_indent = max([l:expected_indent, 0])
    return min([l:expected_indent, l:indent])
endfunction

set indentexpr=s:GetRustIndent()
