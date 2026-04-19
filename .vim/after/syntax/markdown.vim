" Working as of Debian trixie, vim 2:9.1.1230-2 (Vim 9.1 with patches 1-948,
" 950-1230, 1242, 1244).

let s:link_text = '[^^]\%(\_[^][]*\%(\[\_[^][]*\]\)\?\)*'

" Highlight shortcut reference links; e.g., the first 'This' in:
"
"     [This] is a shortcut link.
"
"     [This]: https://example.com
"
" This also stops `b` in `[a] (b)` or `[a] [b]` from being highlighted as a
" link destination or link label, which aligns with CommonMark.
execute 'syn region markdownLinkText'
    \ . ' matchgroup=markdownLinkTextDelimiter'
    \ . ' start="\[\%(' . s:link_text . '\][[(]\@!\)\@="'
    \ . ' end="\]"'
    \ . ' skipwhite'
    \ . ' contains=@markdownInline,markdownLineStart'

" Ensure link reference definitions take priority over shortcut reference
" links. Also allow the URL to be on the next line.
syn clear markdownIdDeclaration
execute 'syn region markdownIdDeclaration'
    \ . ' matchgroup=markdownLinkDelimiter'
    \ . ' start="^ \{0,3\}\[\%(' . s:link_text . '\]:\)\@="'
    \ . ' end="\]:"'
    \ . ' oneline'
    \ . ' keepend'
    \ . ' nextgroup=markdownUrl'
    \ . ' skipwhite'
    \ . ' skipnl'

" Make code spans transparent, so when used in a link or heading, they take on
" the parent's highlighting.
syn clear markdownCode
syn region markdownCode
    \ matchgroup=markdownCodeDelimiter
    \ start="\%(```\)\@!\z(``\?\)"
    \ end="\z1"
    \ keepend
    \ contains=markdownLineStart
    \ transparent
