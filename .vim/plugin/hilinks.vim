" Modified version of hilinks.vim
"
" This file contains code originally from hilinks.vim, which is covered by the
" following copyright and license notice:
"
"     Author:  Charles E. Campbell  <NdrOchip@ScampbellPfamily.AbizM>
"               (remove NOSPAM from Campbell's email first)
"     Copyright: (c) 2008-2013 by Charles E. Campbell
"                The VIM LICENSE applies to hilinks.vim, and hilinks.txt
"                (see |copyright|) except use "hilinks" instead of "Vim"
"                NO WARRANTY, EXPRESS OR IMPLIED.  USE AT-YOUR-OWN-RISK.
"
" All modifications in this file compared to the original are released under
" the same license as the original.

if exists("g:loaded_hilinks")
    finish
endif
let g:loaded_hilinks = "v4"
if v:version < 700
    echohl WarningMsg
    echo "***warning*** this version of hilinks needs vim 7.0"
    echohl Normal
    finish
endif

let s:HLTmode = 0
command HiLinkTrace call HiLinkTrace()

" this function traces the highlighting group names from transparent/top level
" through to the bottom
function HiLinkTrace()
    " save register a
    let keep_rega = @a

    " get highlighting linkages into register "a"
    redir @a
        silent! hi
    redir END

    " initialize with top-level highlighting
    let curline = line(".")
    let curcol = col(".")
    let firstlink = synIDattr(synID(curline,curcol,1),"name")
    let lastlink = synIDattr(synIDtrans(synID(curline,curcol,1)),"name")
    let translink = synIDattr(synID(curline,curcol,0),"name")

    " if transparent link isn't the same as the top highlighting link,
    " then indicate it with a leading "T:"
    if firstlink != translink
        let hilink = "T:".translink."→".firstlink
    else
        let hilink = firstlink
    endif

    " trace through the linkages
    if firstlink != lastlink
        let no_overflow = 0
        let curlink = firstlink
        while curlink != lastlink && no_overflow < 10
            let no_overflow = no_overflow + 1
            let nxtlink = substitute(@a,'^.*\<'.curlink.
                        \'\s\+xxx links to \(\a\+\).*$','\1','')
            if nxtlink =~# '\<start=\|\<cterm[fb]g=\|\<gui[fb]g='
                let nxtlink = substitute(nxtlink,'^[ \t\n]*\(\S\+\)\s\+.*$',
                            \'\1','')
                let hilink = hilink."→".nxtlink
                break
            endif
            let hilink = hilink."→".nxtlink
            let curlink = nxtlink
        endwhile
    endif

    " Use new synstack() function, available with 7.1 and patch#215
    if v:version > 701 || (v:version == 701 && has("patch215"))
        let syntaxstack = ""
        let isfirst = 1
        let idlist = synstack(curline,curcol)
        if !empty(idlist)
            for id in idlist
                if isfirst
                    let syntaxstack = syntaxstack.synIDattr(id,"name")
                    let isfirst = 0
                else
                    let syntaxstack = syntaxstack."→".synIDattr(id,"name")
                endif
            endfor
        endif
    endif

    " display hilink traces
    redraw
    let synid = hlID(lastlink)
    let retval = hilink
    if exists("syntaxstack")
        let retval = syntaxstack." ".retval
    endif
    echo retval

    " restore register a
    let @a = keep_rega
    return retval
endfun
