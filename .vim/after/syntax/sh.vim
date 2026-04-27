" Working as of Debian trixie, vim 2:9.1.1230-2 (Vim 9.1 with patches 1-948,
" 950-1230, 1242, 1244).

" * Fix highlighting of `if x; then if { y; z; }; then...`.
" * Recognize more function names in Bash.
" * Recognize nested function definitions.
" * Recognize non-top-level `f() (...)`-style functions.
if exists("b:is_bash")
    let s:func_name='[[:keyword:]+.]\+'
else
    let s:func_name='\h\w*'
endif
syn clear shFunctionOne shFunctionThree
execute 'syn region shFunctionOne matchgroup=shFunction start="'
    \ . s:func_name . '\s*()\_s*{" end="}" contains=@shFunctionList'
execute 'syn region shFunctionThree matchgroup=shFunction start="'
    \ . s:func_name . '\s*()\_s*(" end=")" contains=@shFunctionList'
syn cluster shIfList remove=shFunctionTwo
syn cluster shCommandSubList add=shFunctionOne,shFunctionThree

" Highlight continuation backslashes in functions and if blocks.
syn cluster shCommandSubList add=shWrapLineOperator

" Don't highlight top-level `(foo)` as an arithmetic expression.
syn clear shParen

" Highlight operators in top-level statements too.
syn match shOperator "[!&;|]"

" Reduce false positive highlighting of child path components as keywords;
" e.g., `cat ./case`.
syn match shNotKeyword "/[[:keyword:].]\+" transparent contains=NONE
syn cluster shCommandSubList add=shNotKeyword

" Don't highlight `set-foo` as a `set` invocation. The root cause is a
" misplaced `\>` in the upstream syntax file; this is a workaround.
syn match shNotKeyword "\<set\>\@!"

" Treat `$(` as the start of a command substitution even when followed by a
" newline.
syn clear shCommandSub
syn region shCommandSub matchgroup=shCmdSubRegion
    \ start="\$((\@!" skip="\\." end=")"
    \ contains=@shCommandSubList

" Highlight `local` the same way as `export`.
syn keyword shStatement local
