" Modified version of securemodelines.vim
"
" This file contains code originally from securemodelines.vim, which is
" licensed under 'the same terms as Vim itself'. The license of Vim as it
" appeared throughout the period during which the original securemodelines.vim
" was created and/or published (Jul 9, 2009 to Sep 5, 2015) is included in the
" file 'licenses/Vim-7.0' at the root of the repository
" (https://codeberg.org/taylordotfish/taylordotfiles).
"
" All modifications in this file are released under the same license as the
" original. See the 'Original header' below for more information about the
" original securemodelines.vim.

" Original header:
" Script:           securemodelines.vim
" Author:           Ciaran McCreesh <ciaran.mccreesh at googlemail.com>
" Homepage:         http://github.com/ciaranm/securemodelines
" Requires:         Vim 7
" License:          Redistribute under the same terms as Vim itself
" Purpose:          A secure alternative to modelines

if &compatible || v:version < 700 || exists('g:loaded_securemodelines')
    finish
endif
let g:loaded_securemodelines = 1
if get(g:, "secure_modelines_disabled", 0)
    finish
endif

set nomodeline

if !exists("g:secure_modelines_allowed_items")
    let g:secure_modelines_allowed_items = [
        \ "filetype", "ft",
        \ "textwidth", "tw",
        \ "shiftwidth", "sw",
        \ "tabstop", "ts",
        \ "softtabstop", "sts",
        \ "expandtab", "et",
        \ "noexpandtab", "noet",
        \ "foldmethod", "fdm",
    \ ]
endif

function s:ProcessArg(arg) abort
    let l:matches = matchlist(
        \ a:arg,
        \ '^\([a-z]\+\)\%([-+^]\?=[A-Za-z0-9,._-]\+\)\?$'
    \ )
    if empty(l:matches)
        return
    endif
    if index(g:secure_modelines_allowed_items, l:matches[1]) >= 0
        execute "setlocal " . a:arg
    endif
endfunction

function s:ProcessLine(line) abort
    let l:matches = matchlist(
        \ a:line,
        \ '\S\@<!\%(vi\|[Vv]im\|ex\):\s*\%(set\s\+\([^:]*\):\|\(.*\)\)',
    \ )
    if empty(l:matches)
        return
    endif
    for l:arg in split(l:matches[1] . l:matches[2], '[[:space:]:]\+')
        call s:ProcessArg(l:arg)
    endfor
endfunction

function s:Run() abort
    let l:end = min([&modelines, line("$")])
    let l:start = min([l:end + 1, line("$") - &modelines + 1])
    for l:line in getline(1, l:end) + getline(l:start, line("$"))
        call s:ProcessLine(l:line)
    endfor
endfunction

augroup SecureModelines
    au!
    au BufRead,StdinReadPost * :call s:Run()
augroup END
